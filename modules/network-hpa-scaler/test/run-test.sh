#!/bin/bash

# exit on any errors
set -e


############################################################
# Include general utility functions and test harness

. ./test-util.sh

############################################################
# Pre-flight validation

check_command kubectl


############################################################
# test-specific utility functions

check_net_connector() {
  echo "pod | app='net-test' | limit=1 | \`ls /tmp/\`" | ${CLI} | grep "connector.py"
}

get_service_ip() {
  kubectl -n "net-test-ns" get service net-test | tr -s ' ' | cut -d' ' -f 3 | grep -v "CLUSTER-IP"
}

run_pod_server() {
  echo 'pods | app = "net-test" | `cd /tmp; chmod +x connector.py; ./connector.py server 5555 >/tmp/server.out 2>/tmp/server.err &`' | ${CLI} 
}

run_pod_client_min() {
  echo 'pods | app = "net-test" | `cd /tmp; chmod +x connector.py; ./connector.py client 50 5555' `get_service_ip` '>/tmp/client.out 2>/tmp/client.err &`' | ${CLI} 
}

run_pod_client_max() {
  echo 'pods | app = "net-test" | `cd /tmp; chmod +x connector.py; ./connector.py client 200 5555' `get_service_ip` '>/tmp/client.out 2>/tmp/client.err &`' | ${CLI} 
}

############################################################
# setup

pods_apt_install() {
  ok_banner "Installing tools and packages in pods..."
  echo " host | pod | app='net-test' | \`apt-get update\` " | ${CLI}
  echo " host | pod | app='net-test' | \`apt-get install -y jq iproute2 python3 procps psmisc\` " | ${CLI}
  echo " host | pod | app='net-test' | \`curl -LO https://dl.k8s.io/release/v1.20.0/bin/linux/amd64/kubectl\` " | ${CLI}
  echo " host | pod | app='net-test' | \`chmod +x kubectl; mv kubectl /bin/\` " | ${CLI}
}

do_setup_kube() {
  echo "Setting up k8s objects (pods)"
  # XXX should we pre-delete any existing pods -- just in case

  kubectl apply -f ./net_test.yaml
  # dynamically check for pod...
  echo "waiting for net-test pod creation ..."
  used=0
  until check_pod_by_app net-test; do
    echo "  waiting..."
    sleep ${PAUSE_TIME}
    # timeout after maximum wait and fail
    used=$(( ${used} + ${PAUSE_TIME} ))
    if [ ${used} -gt ${MAX_WAIT} ]; then
      do_timeout "pod creation"
    fi
  done
  check_pod_by_app net-test
  sleep 10

  pods_apt_install
  
  echo "a little quiet time for the pod to stabilize and register ..."
  sleep 20
}

############################################################
# cleanup

do_cleanup_kube() {
  echo "Cleaning up k8s objects (pods)"
  kubectl -n net-test-ns delete pod,deployment,role,rolebinding --all
  kubectl -n net-test-ns delete sa net-test-sa
}

############################################################
# actual tests

run_tests() {
  # verify that the net-test pod resource was created
  pods=`echo "pod | app='net-test' | count" | ${CLI} | grep -A1 'RESOURCE_COUNT' | tail -n1`


  # dynamically wait for the connector file to propagate
  echo "waiting for connector file to propagate ..."
  used=0
  while [ ! check_net_connector ]; do
    echo "  waiting..."
    sleep ${PAUSE_TIME}
    # timeout after maximum wait and fail
    used=$(( ${used} + ${PAUSE_TIME} ))
    if [ ${used} -gt ${MAX_WAIT} ]; then
      do_timeout "connector.py propagation"
    fi
  done

  # count alarms before we started
  pre_fired=`get_event_counts net | cut -d '|' -f 3`
  pre_cleared=`get_event_counts net | cut -d '|' -f 4`

  pre_pod_count=`count_pods_by_app net-test`
  echo "Starting socket server..."
  run_pod_server
  echo "Starting socket client (sub-threshold)..."
  run_pod_client_min

  ok_banner "Waiting for alarm to (not) fire..."
  sleep 20
  mid_fired=`get_event_counts net | cut -d '|' -f 3`

  if [ "${mid_fired}" != "${pre_fired}" ]; then
    error_banner "ERROR: Alarm fired when below threshold!"
    do_cleanup
    exit 1
  fi

  echo "Starting socket client (over-threshold)..."
  run_pod_client_max

  echo "waiting for resize alarm to fire ..."
  # verify that the alarm fired:
  post_fired=`get_event_counts net | cut -d '|' -f 3`
  get_event_counts net
  used=0
  while [ "${post_fired}" == "${pre_fired}" ]; do
    echo "  waiting..."
    sleep ${PAUSE_TIME}
    post_fired=`get_event_counts net | cut -d '|' -f 3`
    # timeout after maximum wait and fail
    used=$(( ${used} + ${PAUSE_TIME} ))
    if [ ${used} -gt ${MAX_WAIT} ]; then
      do_timeout "alarm to fire"
    fi
  done

  echo "  waiting for new pods to spin up..."
  post_pod_count=`count_pods_by_app net-test`
  used=0
  while [ "${pre_pod_count}" == "${post_pod_count}" ]; do
    echo "  waiting... (${pre_pod_count} vs ${post_pod_count})"
    sleep ${PAUSE_TIME}
    post_pod_count=`count_pods_by_app net-test`
    # timeout after maximum wait and fail
    used=$(( ${used} + ${PAUSE_TIME} ))
    if [ ${used} -gt ${MAX_WAIT} ]; then
      do_timeout "extra pods to spin up"
    fi
  done

  sleep 10
  pods_apt_install
  run_pod_server

  echo "waiting for resize alarm to clear ..."
  post_cleared=`get_event_counts net | cut -d '|' -f 4`
  used=0
  while [ "${post_cleared}" == "${pre_cleared}" ]; do
    echo "  waiting..."
    sleep ${PAUSE_TIME}
    post_cleared=`get_event_counts net | cut -d '|' -f 4`
    # timeout after maximum wait and fail
    used=$(( ${used} + ${PAUSE_TIME} ))
    if [ ${used} -gt ${MAX_WAIT} ]; then
      do_timeout "alarm to clear"
    fi
  done

  if  [ "${post_cleared}" == "${pre_cleared}" ]; then
    error_banner "ERROR: Alarm failed to fire!"
  else
    ok_banner "Successfully resized HPA."
    RETURN_CODE=0
  fi
}

main

############################################################
# useful kubectl/shell commands
#
# kubectl -n "net-test-ns" get service
# chmod +x ../data/net_scale_hpa.sh; NAMESPACE="net-test-ns" AUTOSCALER="net-test-hpa" HPA_MAX="10" INCREMENT="1" ../data/net_scale_hpa.sh
# kubectl -n "net-test-ns" get hpa "net-test-hpa" -o json | jq '.spec+.status|{min:.minReplicas,max:.maxReplicas,cur:.currentReplicas,want:.desiredReplicas}'
# 
############################################################
# useful op commands
#
# pods | app = "net-test" | `ls /tmp`
# pods | app = "net-test" | net_connections_to_local_port('tcp', '5555')
# pods | app = "net-test" | net_connections_to_local_port(PROTO='tcp', PORT='5555')
# pods | app = "net-test" | `cd /tmp; chmod +x connector.py; ./connector.py server 5555 >/tmp/server.out 2>/tmp/server.err &`
# pods | app = "net-test" | `cd /tmp; chmod +x connector.py; ./connector.py client 50 5555 127.0.0.1 >/tmp/client.out 2>/tmp/client.err &`
# pods | app = "net-test" | filter( net_connections_to_local_port(PROTO='tcp', PORT='5555') >= 200 )
# pods | app = "net-test" | filter( net_connections_to_local_port_gt(PROTO='tcp', PORT='5555', THRESH=240) )
# pods | app='net-test' | `ps afx | grep connector.py | grep -v 'bash\|grep' | tr -s ' ' | cut -d' ' -f 2 | xargs kill`
# pods | app="net-test" | limit=1 | `ps afxwww | grep connector | grep -v bash | grep client | tr -s ' ' | cut -d' ' -f2 | xargs kill`

# events | alarm_name =~ "pvc" | count
#   GROUP     | EVENT_TYPE | FIRED | CLEARED | TOTAL_COUNT 
#   group_all | ALARMS     | 1     | 0       | 1           
#   38        | ALARMS     | 1     | 0       | 1           


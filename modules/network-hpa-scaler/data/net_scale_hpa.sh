#!/bin/bash

tmp_file="/tmp/${NAMESPACE}-${AUTOSCALER}-hpa.json"
kubectl -n ${NAMESPACE} get hpa ${AUTOSCALER} -o json >${tmp_file}

min_repl=$(cat ${tmp_file} | jq '.spec.minReplicas')
max_repl=$(cat ${tmp_file} | jq '.spec.maxReplicas')
cur_repl=$(cat ${tmp_file} | jq '.status.currentReplicas')
want_repl=$(cat ${tmp_file} | jq '.status.desiredReplicas')

echo "range: ${min_repl} - ${max_repl}"
echo "status: ${cur_repl} -> ${want_repl}"

if [ "${min_repl}" -gt "${cur_repl}" ]; then
  echo "Scaling up already in progress."
  exit 0
fi
if [ $min_repl -gt $HPA_MAX ]; then
  echo "Already scaled up to maximum."
  exit 1
fi
to_repl=$(( min_repl + INCREMENT ))
if [ $to_repl -gt $HPA_MAX ]; then
  to_repl=$HPA_MAX
fi
echo kubectl -n ${NAMESPACE} patch hpa ${AUTOSCALER} --patch "{\"spec\":{\"minReplicas\":${to_repl}}}"
kubectl -n ${NAMESPACE} patch hpa ${AUTOSCALER} --patch "{\"spec\":{\"minReplicas\":${to_repl}}}"



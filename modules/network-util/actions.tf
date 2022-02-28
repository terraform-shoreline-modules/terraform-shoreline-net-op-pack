
locals {
  # ss: Proto, State, RecvLen, SendLen, LocalAddr, PeerAddr
  ss_local_cmd = "ss -n | grep ESTAB | tr -s ' ' | cut -d' ' -f1,5"
  # netstat: Proto, RecvLen SendLen, LocalAddr, PeerAddr, State
  ns_local_cmd = "netstat -an | grep ESTAB | tr -s ' ' | cut -d' ' -f 1,4"

  ss_remote_cmd = "ss -n | grep ESTAB | tr -s ' ' | cut -d' ' -f1,6"
  ns_remote_cmd = "netstat -an | grep ESTAB | tr -s ' ' | cut -d' ' -f 1,5"
}


# Action to ping remote hosts
resource "shoreline_action" "ping_action" {
  name = "${var.namespace}_ping"
  description = "Ping the remote host at ADDR."
  # Parameters passed in: 
  #  ADDR: the host or address to ping
  params = [ "ADDR" ]
  # Count the connections...
  command = "`ping -c 3 $${ADDR}`"
  # Select the shell to run 'command' with.
  shell = "/bin/sh"
  timeout = 60000 # milliseconds

  # UI / CLI annotation informational messages:
  start_short_template    = "Pinging host."
  error_short_template    = "Error pinging host."
  complete_short_template = "Finished pinging host."
  start_long_template     = "Counting pinging host."
  error_long_template     = "Error pinging host."
  complete_long_template  = "Finished pinging host."

  enabled = true
}

# Action to lookup remote hosts
resource "shoreline_action" "dig_ip_action" {
  name = "${var.namespace}_dig_ip"
  description = "Lookup IP entries for a remote host at ADDR."
  # Parameters passed in: 
  #  ADDR: the host or address to lookup
  params = [ "ADDR" ]
  # Count the connections...
  command = "`dig +noall +question +answer $${ADDR}`"
  # Select the shell to run 'command' with.
  shell = "/bin/sh"
  timeout = 60000 # milliseconds

  # UI / CLI annotation informational messages:
  start_short_template    = "Looking up host."
  error_short_template    = "Error looking up host."
  complete_short_template = "Finished looking up host."
  start_long_template     = "Counting looking up host."
  error_long_template     = "Error looking up host."
  complete_long_template  = "Finished looking up host."

  enabled = true
}

# Action to curl a URL
resource "shoreline_action" "curl_action" {
  name = "${var.namespace}_curl"
  description = "Curl the given URL."
  # Parameters passed in: 
  #  ENDPOINT: the URL to curl
  params = [ "URL" ]
  # Count the connections...
  command = "`curl -s -o /dev/null -w \"%%{http_code}\" $${URL}`"
  # Select the shell to run 'command' with.
  shell = "/bin/sh"
  timeout = 60000 # milliseconds

  # UI / CLI annotation informational messages:
  start_short_template    = "Curling URL."
  error_short_template    = "Error curling URL."
  complete_short_template = "Finished curling URL."
  start_long_template     = "Counting curling URL."
  error_long_template     = "Error curling URL."
  complete_long_template  = "Finished curling URL."

  enabled = true
}

# Action to get curl status from a URL
resource "shoreline_action" "curl_status_action" {
  name = "${var.namespace}_curl_status"
  description = "Curl the given URL and return the status code."
  # Parameters passed in: 
  #  ENDPOINT: the URL to curl
  params = [ "URL" ]
  # Count the connections...
  command = "`status_code=$(curl -s -o /dev/null -w \"%%{http_code}\" $${URL})`"
  res_env_var = "status_code"
  # Select the shell to run 'command' with.
  shell = "/bin/sh"
  timeout = 60000 # milliseconds

  # UI / CLI annotation informational messages:
  start_short_template    = "Getting curl status code for URL."
  error_short_template    = "Error getting curl status code for URL."
  complete_short_template = "Finished getting curl status code for URL."
  start_long_template     = "Counting getting curl status code for URL."
  error_long_template     = "Error getting curl status code for URL."
  complete_long_template  = "Finished getting curl status code for URL."

  enabled = true
}

# Action to calculate number of connections to a local port
# NOTE: This only captures "established" connections, not syn-*/timed-wait/closing/etc
resource "shoreline_action" "connections_to_local_port_gt" {
  name = "${var.namespace}_connections_to_local_port_gt"
  description = "Count the connections to a local port 'PORT' on protocol 'PROTO' (tcp or udp)."
  # Parameters passed in: 
  #  PROTO: protocol, either 'tcp' or 'udp'
  #  PORT: port number of connnections to include 
  #  THRESH: connection count threshold, over which the action returns true (exit code 0)
  params = [ "PROTO", "PORT", "THRESH" ]
  # NOTES: 
  #   could filter out connections with "WAIT", or only count "ESTABLISHED", ignoring half-closed, etc.
  #   this includes both IPv4 and IPv6
  # Count the connections...
  command = "`CONXNS=$(if command -v ss >/dev/null; then ${local.ss_local_cmd}; else ${local.ns_local_cmd}; fi | grep -i $${PROTO} | grep -e \":$${PORT}\\b\" | wc -l | tr -d '\\n'); echo -n $CONXNS; if [ \"$CONXNS\" -gt \"$THRESH\" ]; then exit 0; else exit 1; fi`"
  #res_env_var="CONXNS"
  # Select the shell to run 'command' with.
  shell = "/bin/sh"
  timeout = 60000 # milliseconds

  # UI / CLI annotation informational messages:
  start_short_template    = "Counting network connections."
  error_short_template    = "Error counting network connections."
  complete_short_template = "Finished counting network connections."
  start_long_template     = "Counting local network connections."
  error_long_template     = "Error counting local network connections."
  complete_long_template  = "Finished counting local network connections."

  enabled = true
}

# Action to calculate number of connections to a local port
# NOTE: This only captures "established" connections, not syn-*/timed-wait/closing/etc
resource "shoreline_action" "connections_to_local_port" {
  name = "${var.namespace}_connections_to_local_port"
  description = "Count the connections to a local port 'PORT' on protocol 'PROTO' (tcp or udp)."
  # Parameters passed in: 
  #  PROTO: protocol, either 'tcp' or 'udp'
  #  PORT: port number of connnections to include 
  params = [ "PROTO", "PORT" ]
  # NOTE: could filter out connections with "WAIT", or only count "ESTABLISHED", ignoring half-closed, etc.
  # NOTE: this includes both IPv4 and IPv6
  # Count the connections...
  command = "`CONXNS=$(if command -v ss >/dev/null; then ${local.ss_local_cmd}; else ${local.ns_local_cmd}; fi | grep -i $${PROTO} | grep -e \":$${PORT}\\b\" | wc -l | tr -d '\\n'); echo -n $CONXNS`"
  res_env_var="CONXNS"
  # Select the shell to run 'command' with.
  shell = "/bin/sh"
  timeout = 60000 # milliseconds

  # UI / CLI annotation informational messages:
  start_short_template    = "Counting network connections."
  error_short_template    = "Error counting network connections."
  complete_short_template = "Finished counting network connections."
  start_long_template     = "Counting local network connections."
  error_long_template     = "Error counting local network connections."
  complete_long_template  = "Finished counting local network connections."

  enabled = true
}


# Action to calculate number of connections to a remote port
resource "shoreline_action" "connections_to_remote_port" {
  name = "${var.namespace}_connections_to_remote_port"
  description = "Count the connections to a remote port 'PORT' on protocol 'PROTO' (tcp or udp)."
  # Parameters passed in: 
  #  PROTO: protocol, either 'tcp' or 'udp'
  #  PORT: port number of connnections to include 
  params = [ "PROTO", "PORT" ]
  # Count the connections...
  command = "`CONXNS=$(if command -v ss >/dev/null; then ${local.ss_remote_cmd}; else ${local.ns_remote_cmd}; fi | grep -i $${PROTO} | grep -e \":$${PORT}\\b\" | wc -l | tr -d '\\n'); echo -n $CONXNS`"
  res_env_var="CONXNS"
  # Select the shell to run 'command' with.
  shell = "/bin/sh"
  timeout = 60000 # milliseconds

  # UI / CLI annotation informational messages:
  start_short_template    = "Counting network connections."
  error_short_template    = "Error counting network connections."
  complete_short_template = "Finished counting network connections."
  start_long_template     = "Counting remote network connections."
  error_long_template     = "Error counting remote network connections."
  complete_long_template  = "Finished counting remote network connections."

  enabled = true
}

output "connections_to_local_port__action_name" {
  value = shoreline_action.connections_to_local_port.name
}

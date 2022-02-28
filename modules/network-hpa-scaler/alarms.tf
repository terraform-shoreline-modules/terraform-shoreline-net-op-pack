# Alarm that triggers when the connection count exceeds a threshold.
resource "shoreline_alarm" "net_connection_count_alarm" {
  name = "${var.namespace}_net_connection_count_alarm"
  description = "Alarm on network connection count growing larger than a threshold."
  # The query that triggers the alarm: is the connection count greater than a threshold.
  #fire_query  = "${shoreline_action.connections_to_local_port.name}('${var.protocol}', '${var.port}') >= ${var.connection_threshold}"
  fire_query  = "${module.network_util.connections_to_local_port__action_name}('${var.protocol}', '${var.port}') >= ${var.connection_threshold}"
  #fire_query  = "${shoreline_action.connections_to_local_port_gt.name}('${var.protocol}', '${var.port}', ${var.connection_threshold})"
  # The query that ends the alarm: is the connection count lower than the threshold.
  #clear_query = "${shoreline_action.connections_to_local_port.name}('${var.protocol}', '${var.port}') < ${var.connection_threshold}"
  clear_query = "${module.network_util.connections_to_local_port__action_name}('${var.protocol}', '${var.port}') < ${var.connection_threshold}"
  # How often is the alarm evaluated. This is a more slowly changing metric, so every 60 seconds is fine.
  check_interval_sec = "${var.check_interval}"
  # User-provided resource selection
  resource_query = "${var.resource_query}"

  # UI / CLI annotation informational messages:
  fire_short_template = "Network connection count approaching capacity threshold."
  resolve_short_template = "Network connection count below capacity threshold."
  # include relevant parameters, in case the user has multiple instances on different volumes/resources
  fire_long_template = "Network connection count (${var.protocol} port: ${var.port}) approaching capacity threshold ${var.connection_threshold} on ${var.resource_query}"
  resolve_long_template = "Network connection count (${var.protocol} port: ${var.port}) below capacity threshold ${var.connection_threshold} on ${var.resource_query}"

  # low-frequency, and a linux command, so compiling won't help
  compile_eligible = false

  # alarm is raised local to a resource (vs global)
  raise_for = "local"
  # raised on a linux command (not a standard metric)
  metric_name = "connections_to_local_port"
  # threshold value
  condition_value = "${var.connection_threshold}"
  # fires when above the threshold
  condition_type = "above"
  # general type of alarm ("metric", "custom", or "system check")
  family = "custom"

  enabled = true
}


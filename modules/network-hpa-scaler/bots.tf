# Bot that fires the resize action when the network connection count exceeds the chosen threshold.
resource "shoreline_bot" "network_hpa_resize_bot" {
  name = "${var.namespace}_network_hpa_resize_bot"
  description = "Network connection capacity handler bot"
  # If the connection counts are more than the threshold, increase available pods.
  # NOTE: Use a reference to the action and alarm, to ensure they are created and available before the bot.
  command = "if ${shoreline_alarm.net_connection_count_alarm.name} then ${shoreline_action.network_hpa_resize.name}() fi"

  # general type of bot this can be "standard" or "custom"
  family = "custom"

  enabled = true
}


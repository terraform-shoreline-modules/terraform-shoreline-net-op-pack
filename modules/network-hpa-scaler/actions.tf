
# Action to perform the HPA resize
resource "shoreline_action" "network_hpa_resize" {
  name = "${var.prefix}network_hpa_resize"
  description = "Resize horizontal pod autoscaler (HPA)"
  # Run the resize script (which was copied by a file object).
  command = "`cd ${var.script_path} && chmod +x ./net_scale_hpa.sh && NAMESPACE=\"${var.hpa_namespace}\" AUTOSCALER=\"${var.hpa_name}\" HPA_MAX=\"${var.max_size}\" INCREMENT=\"${var.increment}\" ./net_scale_hpa.sh`"
  # Parameters ...
  params = []
  resource_query = "${var.resource_query} | limit=1 "

  # UI / CLI annotation informational messages:
  start_short_template    = "Resizing HPA."
  error_short_template    = "Error resizing HPA."
  complete_short_template = "Finished resizing HPA."
  start_long_template     = "Resizing HPA ${var.hpa_name} up by ${var.increment}, limit: ${var.max_size}."
  error_long_template     = "Error resizing HPA ${var.hpa_name} up by ${var.increment}, limit: ${var.max_size}."
  complete_long_template  = "Finished resizing HPA ${var.hpa_name} up by ${var.increment}, limit: ${var.max_size}."

  enabled = true
}


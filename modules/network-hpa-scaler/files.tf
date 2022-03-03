# Push the script that actually performs the resize to the selected nodes.
resource "shoreline_file" "net_hpa_resize_script" {
  name = "${var.prefix}net_hpa_resize_script"
  description = "Script to resize kubernetes HPA."
  input_file = "${path.module}/data/net_scale_hpa.sh"       # source file (relative to this module)
  destination_path = "${var.script_path}/net_scale_hpa.sh"  # where it is copied to on the selected resources
  resource_query = "${var.resource_query}"                  # which resources to copy to
  enabled = true
}


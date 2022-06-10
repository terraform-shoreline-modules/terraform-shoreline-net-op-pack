# Notebook for network-util module
resource "shoreline_notebook" "network_hpa_scaler_notebook" {
  name = "${var.prefix}network_hpa_scaler_notebook"
  description = "Notebook for testing Horizontal Pod Autoscaler based on the current connection count."
  data = "${path.module}/data/net_hpa_scaler_notebook.json"
}

# Notebook for network-util module
resource "shoreline_notebook" "network_util_notebook" {
  name = "${var.prefix}network_util_notebook"
  description = "Notebook for testing network connectivity and latency across a fleet of machines."
  data = file("${path.module}/data/net_util_notebook.json")
}

terraform {
  required_providers {
    shoreline = {
      source  = "shorelinesoftware/shoreline"
      version = ">= 1.1.3"
    }
  }
}

provider "shoreline" {
  # provider configuration here
  retries = 2
}


module "network_hpa_scaler" {
  # Location of the module
  source = "terraform-shoreline-modules/net-op-pack/shoreline//modules/network-hpa-scaler"

  # Frequency to evaluate alarm conditions in seconds
  check_interval = 60

  # Namespace to allow multiple instances of the module, with different params
  namespace = "net_example"

  # Resource query to select the affected resources
  resource_query = "pods | app='net-test'"

  # Destination of the memory-check, and trace scripts on the selected resources
  script_path = "/tmp"

  # Kubernetes namespace of the horizontal pod autoscaler
  hpa_namespace      = "net-test-ns"

  # Kubernetes name of the horizontal pod autoscaler
  hpa_name           = "net-test-hpa"

  # The port to monitor for connection counts
  port               = 5555

  # The protocol "tcp" or "udp" to monitor
  protocol           = "tcp"

  # The connection count that will trigger a resize
  connection_threshold = 200

  # The maximum number of pods to scale the HPA to
  max_size           = 10

  # Amount of pods to increase by on each alarm invocation
  increment          = 3

  # how frequently to evaluate the alarms
  check_interval     = 60

  providers = { 
    #shoreline = shoreline.main
    shoreline = shoreline
  }
}

 
terraform {
  required_providers {
    shoreline = {
      source  = "shorelinesoftware/shoreline"
      version = ">= 1.2.2"
      #configuration_aliases = [ shoreline.main ]
    }
  }
}

provider "shoreline" {
  # provider configuration here
  #url = "${var.shoreline_url}"
  retries = 2
  debug = true
  #alias = "main"
}


locals {
  namespace          = "net"
}

# NAMESPACE="net-test-ns" AUTOSCALER="net-test-hpa" HPA_MAX="10" INCREMENT="1" ../data/net_scale_hpa.sh
# kubectl -n "net-test-ns" get hpa "net-test-hpa" -o json | jq '.spec+.status|{min:.minReplicas,max:.maxReplicas,cur:.currentReplicas,want:.desiredReplicas}'

module "network_hpa_scaler" {
  #url = "${var.shoreline_url}"
  source             = "../"
  namespace          = "${local.namespace}"
  port               = 5555
  protocol           = "tcp"
  resource_query     = "pods | app='net-test'"
  hpa_namespace      = "net-test-ns"
  hpa_name           = "net-test-hpa"
  # check more frequently to speed up test
  check_interval     = 10
  connection_threshold = 200
  max_size           = 10
  increment          = 3
  #resize_script_path = "/tmp"
  script_path = "/tmp"

  providers = { 
    #shoreline = shoreline.main
    shoreline = shoreline
  }
}

# Push the client/server script that creates connections.
resource "shoreline_file" "net_connector_script" {
  name = "${local.namespace}_net_connector_script"
  description = "client/server python script."
  input_file = "${path.module}/connector.py"
  destination_path = "/tmp/connector.py"
  resource_query = "pods | app='net-test'"
  enabled = true
}


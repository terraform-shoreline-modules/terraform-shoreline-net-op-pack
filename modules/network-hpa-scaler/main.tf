################################################################################
# Module: network
# 
# Automatically expand k8s HPA, if the connection count to a specific port 
# exceeds a threshold.
#
# Example usage:
#
#   module "network" {
#     # Location of the module:
#     source             = "./"
#   
#     # Namespace to allow multiple instances of the module, with different params:
#     namespace          = "net"
#   
#     # Resource query to select the affected resources:
#     resource_query     = "net-test"
#   
#   
#     # Destination of the resize script on the selected resources:
#     resize_script_path = "/tmp/"
#   }

################################################################################

terraform {
  required_providers {
    shoreline = {
      source  = "shorelinesoftware/shoreline"
    }
  }
}

#provider "shoreline" {
#  # provider configuration here
#  #url = "${var.shoreline_url}"
#  retries = 2
#  debug = true
#}

module "network_util" {
  source = "../network-util"
  namespace = var.namespace
  providers = {
    shoreline = shoreline
  }
}

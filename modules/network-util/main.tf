################################################################################
# Module: network-util
# 
# Test latency, connectivity, htttp response codes, and connection counts 
# across resources.
#
# Example usage:
#
#   module "network" {
#     # Location of the module:
#     source             = "./"
#   
#     # Prefix to allow multiple instances of the module, with different params:
#     prefix          = "net_"
#   
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



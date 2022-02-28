
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


module "network_util" {
  # Location of the module
  source = "terraform-shoreline-modules/net-op-pack/shoreline//modules/network-util"

  # Namespace to allow multiple instances of the module, with different params
  namespace = "net"

  providers = { 
    #shoreline = shoreline.main
    shoreline = shoreline
  }
}

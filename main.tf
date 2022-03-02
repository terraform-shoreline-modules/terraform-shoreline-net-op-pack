# ---------------------------------------------------------------------------------------------------------------------
# ENVIRONMENT VARIABLES
# Define these parameters/secrets as environment variables
# ---------------------------------------------------------------------------------------------------------------------

# SHORELINE_URL   - The API url for your shoreline cluster, i.e. "https://<customer>.<region>.api.shoreline-<cluster>.io"
# SHORELINE_TOKEN - The alphanumeric access token for your cluster. (Typically from Okta.)

terraform {
  # Setting 0.13.1 as the minimum version. Older versions are missing significant features.
  required_version = ">= 0.13.1"

  #required_providers {
  #  shoreline = {
  #    source  = "shorelinesoftware/shoreline"
  #    version = ">= 1.2.2"
  #  }
  #}
}


provider "shoreline" {
  # provider configuration here
  retries = 2
  debug = true
}

# Example instantiation of the JVM Trace OpPack:
module "net_example" {
  source             = "./modules/network-hpa-scaler"
  namespace          = "net_example"

  port               = 5555
  protocol           = "tcp"
  resource_query     = "pods | app='net-test'"

  check_interval     = 60
  script_path        = "/tmp"

  hpa_namespace      = "net-test-ns"
  hpa_name           = "net-test-hpa"
  connection_threshold = 200
  max_size           = 10
  increment          = 3

  providers = { 
    shoreline = shoreline
  }
}


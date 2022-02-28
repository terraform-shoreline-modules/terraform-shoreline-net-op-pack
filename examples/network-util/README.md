# Network Util Op Pack Example

This document contains configuration and usage examples of the [Network Util Op Pack](https://github.com/terraform-shoreline-modules/terraform-shoreline-net-op-pack/tree/main/modules/network-util).

## Requirements

The following tools are required on the monitored resources, with appropriate permissions:

1. The 'ping', 'dig', and 'curl' networking commands
1. Either the 'netcat' or 'ss' networking commands.

## Example

The following example sets up utility actions to debug and diagnose connection, routing, latency, DNS, and HTTP issues across a swath of resources (hosts/pods/containers).

```hcl
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
  namespace = "net_example"

  providers = { 
    #shoreline = shoreline.main
    shoreline = shoreline
  }
}
```

## Manual command examples

These commands use Shoreline's expressive [Op language](https://docs.shoreline.io/op) to retrieve fleet-wide data using the generated actions from the Network HPA Scaler module.

-> These commands can be executed within the [Shoreline CLI](https://docs.shoreline.io/installation#cli) or [Shoreline Notebooks](https://docs.shoreline.io/ui/notebooks).

-> See the [shoreline action resource](https://registry.terraform.io/providers/shorelinesoftware/shoreline/latest/docs/resources/action) and the [Shoreline Actions](https://docs.shoreline.io/actions) documentation for details.

### Manually check connection counts on a set of pods

```
op> pods | name =~ 'net-test' | net_connections_to_local_port('tcp', '5555')
```

### Manually check connectivity and latency (via ping to a well known server) on a set of pods

```
op> pods | name =~ 'net-test' | net_ping('8.8.8.8')
```

### Manually check DNS on a set of pods

```
op> pods | name =~ 'net-test' | net_dig_ip('example.com')
```

### Manually check HTTP response code from a set of pods

```
op> pods | name =~ 'net-test' | net_curl('https://www.example.com/')
```


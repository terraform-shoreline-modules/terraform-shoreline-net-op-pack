# Shoreline Network Util Op Pack

<table role="table" style="vertical-align: middle;">
  <thead>
    <tr style="background-color: #fff">
      <th style="padding: 6px 13px; border: 1px solid #B1B1B1; text-align: center;" colspan="3">Provider Support</th>
    </tr>
  </thead>
  <tbody>
    <tr style="background-color: #E2E2E2">
      <td style="padding: 6px 13px; border: 1px solid #B1B1B1; text-align: center;">AWS</td>
      <td style="padding: 6px 13px; border: 1px solid #B1B1B1; text-align: center;">Azure</td>
      <td style="padding: 6px 13px; border: 1px solid #B1B1B1; text-align: center;">GCP</td>
    </tr>
    <tr>
      <td style="padding-top: 6px; vertical-align: bottom; border: 1px solid #B1B1B1; text-align: center;"><svg xmlns="http://www.w3.org/2000/svg" style="width: 1.5rem; height: 1.5rem;" fill="none" viewBox="0 0 24 24" stroke="#6CB169"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" /></svg></td>
      <td style="padding-top: 6px; vertical-align: bottom; border: 1px solid #B1B1B1; text-align: center;"><svg xmlns="http://www.w3.org/2000/svg" style="width: 1.5rem; height: 1.5rem;" fill="none" viewBox="0 0 24 24" stroke="#6CB169"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" /></svg></td>
      <td style="vertical-align: bottom; border: 1px solid #B1B1B1; text-align: center;"><svg xmlns="http://www.w3.org/2000/svg" style="width: 1.5rem; height: 1.5rem;" fill="none" viewBox="0 0 24 24" stroke="#C65858"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" /></svg></td>
    </tr>  
  </tbody>
</table>

The Network Util Op Pack is a collection of actions to test network connectivity and latency across a fleet of machines.

## Requirements

The following tools are required on the monitored resources, with appropriate permissions:

1. The 'ping', 'dig', and 'curl' networking commands
1. Either the 'netcat' or 'ss' networking commands.

## Usage

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
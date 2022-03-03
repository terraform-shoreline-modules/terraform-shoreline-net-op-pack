# Shoreline Network HPA Scaler Op Pack

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

The Network Util Op Pack automatically bumps a Horizontal Pod Autoscaler based on the current connection count.

## Requirements

The following tools are required on the monitored resources, with appropriate permissions:

1. The kubectl commandline (and permissions to modify the HPA).
1. Either the 'netcat' or 'ss' networking commands.

## Usage

The following example monitors all pod resources with an app label of `net-test`. Whenever a targeted pod's connection count on TCP port 5555 exceeds the `connection_threshold` of `200`, the horizontal-pod-autoscaler size is increased by 3, to a maximum of 10 pods.

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


module "network_hpa_scaler" {
  # Location of the module
  source = "terraform-shoreline-modules/net-op-pack/shoreline//modules/network-hpa-scaler"

  # Frequency to evaluate alarm conditions in seconds
  check_interval = 60

  # Prefix to allow multiple instances of the module, with different params
  prefix = "net_example_"

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

  providers = { 
    shoreline = shoreline
  }
}
```

## Manual command examples

These commands use Shoreline's expressive [Op language](https://docs.shoreline.io/op) to retrieve fleet-wide data using the generated actions from the Network HPA Scaler module.

-> These commands can be executed within the [Shoreline CLI](https://docs.shoreline.io/installation#cli) or [Shoreline Notebooks](https://docs.shoreline.io/ui/notebooks).

### Manually check connection counts on a set of pods

```
op> pods | name =~ 'net-test' | net_example_connections_to_local_port('tcp', '5555')
```
-> See the [shoreline action resource](https://registry.terraform.io/providers/shorelinesoftware/shoreline/latest/docs/resources/action) and the [Shoreline Actions](https://docs.shoreline.io/actions) documentation for details.


### List triggered alarms for connection counts

```
op> events | name =~ "net_connection"

 RESOURCE_NAME             | RESOURCE_TYPE | ALARM_NAME                     | STATUS   | STEP_TYPE   | TIMESTAMP                 | DESCRIPTION                                                        
 net-test-5d5bff5c98-cdmp7 | POD           | net_net_connection_count_alarm | resolved |             |                           | Alarm on network connection count growing larger than a threshold. 
                           |               |                                |          | ALARM_FIRE  | 2022-02-27T23:36:33-08:00 | Network connection count approaching capacity threshold.           
                           |               |                                |          | ALARM_CLEAR | 2022-02-27T23:36:53-08:00 | Network connection count below capacity threshold.                 

```

-> See the [Shoreline Events documentation](https://docs.shoreline.io/op/events) for details.

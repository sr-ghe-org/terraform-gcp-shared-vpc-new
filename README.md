
# Shared VPC

## Table of Contents

- [Overview][1]
- [Example Input][2]
- [Requirements][3]
- [Inputs][4]
- [Outputs][5]
- [Modules][6]
- [Resources][7]

## Overview

This module supports the creation of a VPC network (subnets, routers, and firewall rules) within a Google Cloud host project.

**/

## Example Input

```terraform
  #
  #  REQUIRED VARIABLES
  #
  # TODO: update "network_configs" value
  network_configs  = null
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 4.64, < 6 |
| <a name="requirement_google-beta"></a> [google-beta](#requirement\_google-beta) | >= 4.64, < 6 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_network_configs"></a> [network\_configs](#input\_network\_configs) | Template Network Configuration | <pre>object({<br>    vpc = optional(map(object({<br>      project_id                             = string<br>      name                                   = string<br>      routing_mode                           = string<br>      delete_default_internet_gateway_routes = bool<br>      subnets = list(object(<br>        {<br>          subnet_name               = string,<br>          subnet_ip                 = string,<br>          subnet_region             = string,<br>          subnet_private_access     = string,<br>          subnet_flow_logs          = optional(string)<br>          subnet_flow_logs_interval = optional(string)<br>          subnet_flow_logs_sampling = optional(number)<br>          subnet_flow_logs_metadata = optional(string)<br>          purpose                   = optional(string)<br>          role                      = optional(string)<br>        })<br>      )<br>      secondary_ranges = map(list(object({ range_name = string, ip_cidr_range = string })))<br>      routers = optional(map(object({<br>        name   = string<br>        region = string<br><br>      })), {})<br>      firewall_rules = object({<br>        egress = optional(list(object({<br>          name                    = string<br>          description             = optional(string, null)<br>          disabled                = optional(bool, null)<br>          priority                = optional(number, null)<br>          destination_ranges      = optional(list(string), [])<br>          source_ranges           = optional(list(string), [])<br>          source_tags             = optional(list(string))<br>          source_service_accounts = optional(list(string))<br>          target_tags             = optional(list(string))<br>          target_service_accounts = optional(list(string))<br><br>          allow = optional(list(object({<br>            protocol = string<br>            ports    = optional(list(string))<br>          })), [])<br>          deny = optional(list(object({<br>            protocol = string<br>            ports    = optional(list(string))<br>          })), [])<br>          log_config = optional(object({<br>            metadata = string<br>          }))<br>        })), []),<br>        ingress = optional(list(object({<br>          name                    = string<br>          description             = optional(string, null)<br>          disabled                = optional(bool, null)<br>          priority                = optional(number, null)<br>          destination_ranges      = optional(list(string), [])<br>          source_ranges           = optional(list(string), [])<br>          source_tags             = optional(list(string))<br>          source_service_accounts = optional(list(string))<br>          target_tags             = optional(list(string))<br>          target_service_accounts = optional(list(string))<br><br>          allow = optional(list(object({<br>            protocol = string<br>            ports    = optional(list(string))<br>          })), [])<br>          deny = optional(list(object({<br>            protocol = string<br>            ports    = optional(list(string))<br>          })), [])<br>          log_config = optional(object({<br>            metadata = string<br>          }))<br>        })), []),<br>      })<br>    })), {})<br>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_firewall_rules"></a> [firewall\_rules](#output\_firewall\_rules) | n/a |
| <a name="output_project_ids"></a> [project\_ids](#output\_project\_ids) | Map of VPC project IDs |
| <a name="output_router"></a> [router](#output\_router) | n/a |
| <a name="output_vpc"></a> [vpc](#output\_vpc) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_firewall_rules"></a> [firewall\_rules](#module\_firewall\_rules) | terraform-google-modules/network/google//modules/firewall-rules | 9.1.0 |
| <a name="module_router"></a> [router](#module\_router) | terraform-google-modules/cloud-router/google | 6.0 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-google-modules/network/google | 9.1 |

## Resources

No resources.

[1]: #overview
[2]: #example-input
[3]: #requirements
[4]: #inputs
[5]: #outputs
[6]: #modules
[7]: #resources

<!-- BEGIN_TF_DOCS -->
This module supports the creation of a VPC network (subnets, routers, and firewall rules) within a Google Cloud host project.

**/

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 4.64 |
| <a name="requirement_google-beta"></a> [google-beta](#requirement\_google-beta) | >= 4.64 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 4.64 |
| <a name="provider_google-beta"></a> [google-beta](#provider\_google-beta) | >= 4.64 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_firewall_rules"></a> [firewall\_rules](#module\_firewall\_rules) | terraform-google-modules/network/google//modules/firewall-rules | 9.1.0 |
| <a name="module_router"></a> [router](#module\_router) | terraform-google-modules/cloud-router/google | 6.0 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-google-modules/network/google | 9.1 |

## Resources

| Name | Type |
|------|------|
| [google-beta_google_vmwareengine_network_peering.vmw-engine-network-peering](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_vmwareengine_network_peering) | resource |
| [google_compute_address.psc_address](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_forwarding_rule.psc_forwarding_rule](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_forwarding_rule) | resource |
| [google_compute_global_address.private_ip_address](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_address) | resource |
| [google_compute_network_peering.local_network_peering](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network_peering) | resource |
| [google_compute_network_peering_routes_config.peering_routes](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network_peering_routes_config) | resource |
| [google_service_networking_connection.private_service_access](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_networking_connection) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_network_configs"></a> [network\_configs](#input\_network\_configs) | Template Network Configuration | <pre>object({<br>    vpc = optional(map(object({<br>      project_id                             = string<br>      name                                   = string<br>      routing_mode                           = string<br>      delete_default_internet_gateway_routes = bool<br>      reserve_static_ip                      = optional(bool, false)<br>      subnets = list(object(<br>        {<br>          subnet_name                      = string,<br>          subnet_ip                        = string,<br>          subnet_region                    = string,<br>          subnet_private_access            = string,<br>          subnet_private_ipv6_access       = optional(string)<br>          subnet_flow_logs                 = optional(string)<br>          subnet_flow_logs_interval        = optional(string)<br>          subnet_flow_logs_sampling        = optional(number)<br>          subnet_flow_logs_metadata        = optional(string)<br>          subnet_flow_logs_filter          = optional(string)<br>          subnet_flow_logs_metadata_fields = optional(list(string))<br>          description                      = optional(string)<br>          purpose                          = optional(string)<br>          role                             = optional(string)<br>          stack_type                       = optional(string)<br>          ipv6_access_type                 = optional(string)<br>        })<br>      )<br>      secondary_ranges = optional(map(list(object({<br>        range_name    = string<br>        ip_cidr_range = string<br>      }))), {})<br>      routers = optional(map(object({<br>        name   = string<br>        region = string<br>      })), {})<br>      firewall_rules = object({<br>        egress = optional(list(object({<br>          name                    = string<br>          description             = optional(string, null)<br>          disabled                = optional(bool, null)<br>          priority                = optional(number, null)<br>          destination_ranges      = optional(list(string), [])<br>          source_ranges           = optional(list(string), [])<br>          source_tags             = optional(list(string))<br>          source_service_accounts = optional(list(string))<br>          target_tags             = optional(list(string))<br>          target_service_accounts = optional(list(string))<br><br>          allow = optional(list(object({<br>            protocol = string<br>            ports    = optional(list(string))<br>          })), [])<br>          deny = optional(list(object({<br>            protocol = string<br>            ports    = optional(list(string))<br>          })), [])<br>          log_config = optional(object({<br>            metadata = string<br>          }))<br>        })), []),<br>        ingress = optional(list(object({<br>          name                    = string<br>          description             = optional(string, null)<br>          disabled                = optional(bool, null)<br>          priority                = optional(number, null)<br>          destination_ranges      = optional(list(string), [])<br>          source_ranges           = optional(list(string), [])<br>          source_tags             = optional(list(string))<br>          source_service_accounts = optional(list(string))<br>          target_tags             = optional(list(string))<br>          target_service_accounts = optional(list(string))<br><br>          allow = optional(list(object({<br>            protocol = string<br>            ports    = optional(list(string))<br>          })), [])<br>          deny = optional(list(object({<br>            protocol = string<br>            ports    = optional(list(string))<br>          })), [])<br>          log_config = optional(object({<br>            metadata = string<br>          }))<br>        })), []),<br>      }),<br>      dns_peering_config = optional(map(object({<br>        dns_name                           = string<br>        domain                             = string<br>        type                               = optional(string, "peering")<br>        description                        = optional(string, null)<br>        force_destroy                      = optional(bool, false)<br>        private_visibility_config_networks = optional(list(string), [])<br>        target_network                     = optional(string, "")<br>      })), {})<br>      vpc_peering_config = optional(map(object({<br>        vpc_peering_name                          = string<br>        local_network                             = optional(string)<br>        peer_network                              = string<br>        export_peer_custom_routes                 = optional(bool, false)<br>        export_local_custom_routes                = optional(bool, false)<br>        export_peer_subnet_routes_with_public_ip  = optional(bool, false)<br>        export_local_subnet_routes_with_public_ip = optional(bool, true)<br>        stack_type                                = optional(string, "IPV4_ONLY")<br>      })), {})<br>      reserve_ip_for_psa = optional(map(object({<br>        reserve_ip_name = string<br>        address         = string<br>        prefix_length   = string<br>      })), {})<br>      private_service_access = optional(map(object({<br>        network                 = string<br>        reserved_peering_ranges = list(string)<br>        service                 = string<br>        custom_routes = optional(object({<br>          export_custom_routes = optional(bool, false)<br>          import_custom_routes = optional(bool, false)<br>        }))<br>      })), {})<br>    })), {})<br>  })</pre> | n/a | yes |
| <a name="input_private_service_connect"></a> [private\_service\_connect](#input\_private\_service\_connect) | Private Service Connect configuration | <pre>map(object({<br>    project_id               = string<br>    psc_address_name         = string<br>    network_self_link        = string<br>    subnetwork_self_link     = string<br>    psc_forwarding_rule_name = string<br>    psc_service_attachment   = string<br>    region                   = string<br>  }))</pre> | `{}` | no |
| <a name="input_vmw_network_peering"></a> [vmw\_network\_peering](#input\_vmw\_network\_peering) | VMware network peering configuration | <pre>map(object({<br>    name                                = string<br>    description                         = optional(string, null)<br>    peer_network                        = string<br>    peer_network_type                   = optional(string, "STANDARD")<br>    vmware_engine_network               = string<br>    export_custom_routes                = optional(bool, false)<br>    import_custom_routes                = optional(bool, false)<br>    export_custom_routes_with_public_ip = optional(bool, false)<br>    import_custom_routes_with_public_ip = optional(bool, false)<br>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_firewall_rules"></a> [firewall\_rules](#output\_firewall\_rules) | n/a |
| <a name="output_network_ids"></a> [network\_ids](#output\_network\_ids) | Map of VPC network IDs |
| <a name="output_project_ids"></a> [project\_ids](#output\_project\_ids) | Map of VPC project IDs |
| <a name="output_router"></a> [router](#output\_router) | n/a |
| <a name="output_vpc"></a> [vpc](#output\_vpc) | n/a |
<!-- END_TF_DOCS -->
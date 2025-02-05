/**
 * Copyright 2024 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

variable "network_configs" {
  description = "Template Network Configuration"
  type = object({
    vpc = optional(map(object({
      project_id                             = string
      name                                   = string
      routing_mode                           = string
      delete_default_internet_gateway_routes = bool
      reserve_static_ip                      = optional(bool, false)
      subnets = list(object(
        {
          subnet_name                      = string,
          subnet_ip                        = string,
          subnet_region                    = string,
          subnet_private_access            = string,
          subnet_private_ipv6_access       = optional(string)
          subnet_flow_logs                 = optional(string)
          subnet_flow_logs_interval        = optional(string)
          subnet_flow_logs_sampling        = optional(number)
          subnet_flow_logs_metadata        = optional(string)
          subnet_flow_logs_filter          = optional(string)
          subnet_flow_logs_metadata_fields = optional(list(string))
          description                      = optional(string)
          purpose                          = optional(string)
          role                             = optional(string)
          stack_type                       = optional(string)
          ipv6_access_type                 = optional(string)
        })
      )
      secondary_ranges = optional(map(list(object({
        range_name    = string
        ip_cidr_range = string
      }))), {})
      routers = optional(map(object({
        name   = string
        region = string
      })), {})
      firewall_rules = object({
        egress = optional(list(object({
          name                    = string
          description             = optional(string, null)
          disabled                = optional(bool, null)
          priority                = optional(number, null)
          destination_ranges      = optional(list(string), [])
          source_ranges           = optional(list(string), [])
          source_tags             = optional(list(string))
          source_service_accounts = optional(list(string))
          target_tags             = optional(list(string))
          target_service_accounts = optional(list(string))

          allow = optional(list(object({
            protocol = string
            ports    = optional(list(string))
          })), [])
          deny = optional(list(object({
            protocol = string
            ports    = optional(list(string))
          })), [])
          log_config = optional(object({
            metadata = string
          }))
        })), []),
        ingress = optional(list(object({
          name                    = string
          description             = optional(string, null)
          disabled                = optional(bool, null)
          priority                = optional(number, null)
          destination_ranges      = optional(list(string), [])
          source_ranges           = optional(list(string), [])
          source_tags             = optional(list(string))
          source_service_accounts = optional(list(string))
          target_tags             = optional(list(string))
          target_service_accounts = optional(list(string))

          allow = optional(list(object({
            protocol = string
            ports    = optional(list(string))
          })), [])
          deny = optional(list(object({
            protocol = string
            ports    = optional(list(string))
          })), [])
          log_config = optional(object({
            metadata = string
          }))
        })), []),
      }),
      dns_peering_config = optional(map(object({
        dns_name                           = string
        domain                             = string
        type                               = optional(string, "peering")
        description                        = optional(string, null)
        force_destroy                      = optional(bool, false)
        private_visibility_config_networks = optional(list(string), [])
        target_network                     = optional(string, "")
      })), {})
      vpc_peering_config = optional(map(object({
        vpc_peering_name                          = string
        local_network                             = optional(string)
        peer_network                              = string
        export_peer_custom_routes                 = optional(bool, false)
        export_local_custom_routes                = optional(bool, false)
        export_peer_subnet_routes_with_public_ip  = optional(bool, false)
        export_local_subnet_routes_with_public_ip = optional(bool, true)
        stack_type                                = optional(string, "IPV4_ONLY")
      })), {})
      reserve_ip_for_psa = optional(map(object({
        reserve_ip_name = string
        address         = string
        prefix_length   = string
      })), {})
      private_service_access = optional(map(object({
        network                 = string
        reserved_peering_ranges = list(string)
        service                 = string
        custom_routes = optional(object({
          export_custom_routes = optional(bool, false)
          import_custom_routes = optional(bool, false)
        }))
      })), {})
    })), {})
  })
}

variable "private_service_connect" {
  description = "Private Service Connect configuration"
  type = map(object({
    project_id               = string
    psc_address_name         = string
    network_self_link        = string
    subnetwork_self_link     = string
    psc_forwarding_rule_name = string
    psc_service_attachment   = string
    region                   = string
  }))
  default = {}
}

variable "vmw_network_peering" {
  description = "VMware network peering configuration"
  type = map(object({
    name                                = string
    description                         = optional(string, null)
    project                             = string
    peer_network                        = string
    peer_network_type                   = optional(string, "STANDARD")
    vmware_engine_network               = string
    export_custom_routes                = optional(bool, false)
    import_custom_routes                = optional(bool, false)
    export_custom_routes_with_public_ip = optional(bool, false)
    import_custom_routes_with_public_ip = optional(bool, false)
  }))
  default = {}
}





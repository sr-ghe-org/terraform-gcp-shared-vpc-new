/**
 * This module supports the creation of a VPC network (subnets, routers, and firewall rules) within a Google Cloud host project.
 *
 **/
locals {
  routers = merge([
    for vpc_name, vpc_details in var.network_configs.vpc :
    {
      for router_name, router_config in vpc_details.routers :
      "${vpc_name}_${router_name}" => merge(
        router_config,
        { "project_id" = vpc_details.project_id },
        { "vpc_name" = vpc_name }
      )
    }
  ]...)

  # dns_peering = merge([
  #   for vpc_name, vpc_details in var.network_configs.vpc :
  #   {
  #     for dns_name, dns_config in vpc_details.dns_peering_config :
  #     "${vpc_name}_${dns_name}" => merge(
  #       dns_config,
  #       { "project_id" = vpc_details.project_id },
  #       { "vpc_name" = vpc_name }
  #     )
  #   }
  # ]...)

  vpc_peering = merge([
    for vpc_name, vpc_details in var.network_configs.vpc :
    {
      for vpc_peering_name, vpc_peering_config in vpc_details.vpc_peering_config :
      "${vpc_name}_${vpc_peering_name}" => merge(
        vpc_peering_config,
        { "project_id" = vpc_details.project_id },
        { "vpc_name" = vpc_name }
      )
    }
  ]...)

  reserve_ip_for_psa = merge([
    for vpc_name, vpc_details in var.network_configs.vpc :
    {
      for reserve_ip_for_psa_name, reserve_ip_for_psa_config in vpc_details.reserve_ip_for_psa :
      "${vpc_name}_${reserve_ip_for_psa_name}" => merge(
        reserve_ip_for_psa_config,
        { "project_id" = vpc_details.project_id },
        { "vpc_name" = vpc_name }
      )
    }
  ]...)

  psa = merge([
    for vpc_name, vpc_details in var.network_configs.vpc :
    {
      for psa_name, psa_config in vpc_details.private_service_access :
      "${vpc_name}_${psa_name}" => merge(
        psa_config,
        { "project_id" = vpc_details.project_id },
        { "vpc_name" = vpc_name }
      )
    }
  ]...)
}

module "router" {
  source   = "terraform-google-modules/cloud-router/google"
  version  = "6.0"
  for_each = local.routers
  name     = each.value.name
  project  = each.value.project_id
  region   = each.value.region
  network  = module.vpc[each.value.vpc_name].network_name
}

module "vpc" {
  source                                 = "terraform-google-modules/network/google"
  version                                = "9.1"
  for_each                               = var.network_configs.vpc
  project_id                             = each.value.project_id
  network_name                           = each.value.name
  routing_mode                           = each.value.routing_mode
  delete_default_internet_gateway_routes = each.value.delete_default_internet_gateway_routes
  subnets                                = each.value.subnets
  secondary_ranges                       = each.value.secondary_ranges
}

# module "firewall_rules" {
#   source        = "terraform-google-modules/network/google//modules/firewall-rules"
#   version       = "9.1.0"
#   for_each      = var.network_configs.vpc
#   project_id    = each.value.project_id
#   network_name  = module.vpc[each.key].network_name
#   egress_rules  = each.value.firewall_rules.egress
#   ingress_rules = each.value.firewall_rules.ingress
# }

# This has changed
module "firewall_rules" {
  for_each      = length(var.firewall_rules) > 0 ? var.firewall_rules : {}
  source        = "terraform-google-modules/network/google//modules/firewall-rules"
  version       = "9.1.0"
  project_id    = each.value.project_id
  network_name  = module.vpc[each.key].network_name
  egress_rules  = each.value.egress
  ingress_rules = each.value.ingress
}

# module "dns_peering" {
#   source                             = "terraform-google-modules/cloud-dns/google"
#   version                            = "5.3.0"
#   for_each                           = local.dns_peering
#   project_id                         = each.value.project_id
#   type                               = each.value.type
#   name                               = each.value.dns_name
#   domain                             = each.value.domain
#   description                        = each.value.description
#   force_destroy                      = each.value.force_destroy
#   private_visibility_config_networks = [module.vpc[each.value.vpc_name].network_self_link]
#   target_network                     = each.value.target_network
#   depends_on                         = [module.vpc]
# }

resource "google_compute_network_peering" "local_network_peering" {
  for_each             = local.vpc_peering
  name                 = each.value.vpc_peering_name
  network              = module.vpc[each.value.vpc_name].network_self_link
  peer_network         = each.value.peer_network
  export_custom_routes = each.value.export_local_custom_routes
  import_custom_routes = each.value.export_peer_custom_routes

  export_subnet_routes_with_public_ip = each.value.export_local_subnet_routes_with_public_ip
  import_subnet_routes_with_public_ip = each.value.export_peer_subnet_routes_with_public_ip

  stack_type = each.value.stack_type
}

# resource "google_compute_network_peering" "peer_network_peering" {
#   for_each             = local.vpc_peering
#   name                 = each.value.vpc_peering_name
#   network              = each.value.peer_network
#   peer_network         = module.vpc[each.value.vpc_name].network_self_link
#   export_custom_routes = each.value.export_peer_custom_routes
#   import_custom_routes = each.value.export_local_custom_routes

#   export_subnet_routes_with_public_ip = each.value.export_peer_subnet_routes_with_public_ip
#   import_subnet_routes_with_public_ip = each.value.export_local_subnet_routes_with_public_ip

#   stack_type = each.value.stack_type
# }

resource "google_compute_global_address" "private_ip_address" {
  for_each      = local.reserve_ip_for_psa
  project       = each.value.project_id
  name          = each.value.reserve_ip_name
  address       = each.value.address
  prefix_length = each.value.prefix_length
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  network       = module.vpc[each.value.vpc_name].network_self_link
}

resource "google_service_networking_connection" "private_service_access" {
  for_each                = local.psa
  network                 = module.vpc[each.value.vpc_name].network_self_link
  service                 = each.value.service
  reserved_peering_ranges = each.value.reserved_peering_ranges

  depends_on = [google_compute_global_address.private_ip_address]
}

# (Optional) Import or export custom routes
resource "google_compute_network_peering_routes_config" "peering_routes" {
  for_each             = local.psa
  project              = each.value.project_id
  peering              = each.value.network
  network              = module.vpc[each.value.vpc_name].network_name
  import_custom_routes = each.value.custom_routes.import_custom_routes
  export_custom_routes = each.value.custom_routes.export_custom_routes

  # Add this - this is missing
  depends_on = [google_service_networking_connection.private_service_access]
}


# Private Service Connect Module

resource "google_compute_address" "psc_address" {
  for_each     = length(var.private_service_connect) > 0 ? var.private_service_connect : {}
  project      = each.value.project_id
  name         = each.value.psc_address_name
  address_type = "INTERNAL"
  subnetwork   = each.value.subnetwork_self_link
  region       = each.value.region
}

resource "google_compute_forwarding_rule" "psc_forwarding_rule" {
  for_each                = length(var.private_service_connect) > 0 ? var.private_service_connect : {}
  project                 = each.value.project_id
  region                  = each.value.region
  name                    = each.value.psc_forwarding_rule_name
  allow_psc_global_access = true
  network                 = each.value.network_self_link
  subnetwork              = each.value.subnetwork_self_link
  target                  = each.value.psc_service_attachment
  load_balancing_scheme   = ""
  ip_address              = google_compute_address.psc_address[each.key].id

  depends_on = [google_compute_address.psc_address]
}

# Vmware Engine Network Peering [VEN]
resource "google_vmwareengine_network_peering" "vmw-engine-network-peering" {
  # provider                            = google-beta
  for_each                            = length(var.vmw_network_peering) > 0 ? var.vmw_network_peering : {}
  name                                = each.value.name
  description                         = each.value.description
  peer_network                        = each.value.peer_network
  peer_network_type                   = each.value.peer_network_type
  vmware_engine_network               = each.value.vmware_engine_network
  export_custom_routes                = each.value.export_custom_routes
  import_custom_routes                = each.value.import_custom_routes
  export_custom_routes_with_public_ip = each.value.export_custom_routes_with_public_ip
  import_custom_routes_with_public_ip = each.value.import_custom_routes_with_public_ip
}































# WOKRING - DELETED BECAUSE OF THE NAMING CONCERNED
# module "vpc_peering" {
#   source                                    = "terraform-google-modules/network/google//modules/network-peering"
#   version                                   = "~> 10.0"
#   for_each                                  = local.vpc_peering
#   prefix                                    = each.value.vpc_peering_name
#   local_network                             = module.vpc[each.value.vpc_name].network_self_link
#   peer_network                              = each.value.peer_network
#   export_peer_custom_routes                 = each.value.export_peer_custom_routes
#   export_local_custom_routes                = each.value.export_local_custom_routes
#   export_peer_subnet_routes_with_public_ip  = each.value.export_peer_subnet_routes_with_public_ip
#   export_local_subnet_routes_with_public_ip = each.value.export_local_subnet_routes_with_public_ip
#   stack_type                                = each.value.stack_type
# }


# resource "google_compute_address" "reserve_subnet_ips" {
#   for_each = { for vpc_key, vpc_value in var.network_configs.vpc :
#     vpc_key => {
#       for subnet in vpc_value.subnets :
#       "${subnet.subnet_name}" => {
#         subnet_name = subnet.subnet_name
#         subnet_ip   = subnet.subnet_ip
#         region      = subnet.subnet_region
#       }
#     }
#   if vpc_value.reserve_static_ip }

#   project      = var.network_configs.vpc[each.key].project_id
#   name         = "reserved-ip-${each.key}"
#   address_type = "INTERNAL"
#   subnetwork   = module.vpc[each.key].subnets.self_link[each.key]
#   region       = each.value.subnet_region
# }







































# module "vpc_peering" {
#   source                                    = "terraform-google-modules/network/google//modules/network-peering"
#   version                                   = "~> 10.0"
#   prefix                                    = var.prefix
#   local_network                             = var.local_network
#   peer_network                              = var.peer_network
#   export_peer_custom_routes                 = var.export_peer_custom_routes
#   export_local_custom_routes                = var.export_local_custom_routes
#   export_peer_subnet_routes_with_public_ip  = var.export_peer_subnet_routes_with_public_ip
#   export_local_subnet_routes_with_public_ip = var.export_local_subnet_routes_with_public_ip
#   stack_type                                = var.stack_type
# }

# resource "google_compute_network_peering" "local_network_peering" {
#   name                                = each.key
#   network                             = var.local_network
#   peer_network                        = var.peer_network
#   export_custom_routes                = var.export_local_custom_routes
#   import_custom_routes                = var.export_peer_custom_routes
#   export_subnet_routes_with_public_ip = var.export_local_subnet_routes_with_public_ip
#   import_subnet_routes_with_public_ip = var.export_peer_subnet_routes_with_public_ip
#   stack_type                          = var.stack_type
# }

# resource "google_compute_network_peering" "peer_network_peering" {
#   name                                = each.key
#   network                             = var.peer_network
#   peer_network                        = var.local_network
#   export_custom_routes                = var.export_peer_custom_routes
#   import_custom_routes                = var.export_local_custom_routes
#   export_subnet_routes_with_public_ip = var.export_peer_subnet_routes_with_public_ip
#   import_subnet_routes_with_public_ip = var.export_local_subnet_routes_with_public_ip
#   stack_type                          = var.stack_type
# }
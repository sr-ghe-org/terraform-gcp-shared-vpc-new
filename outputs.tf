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

output "vpc" {
  value = module.vpc
}

output "router" {
  value = module.router
}

output "firewall_rules" {
  value = module.firewall_rules
}

output "project_ids" {
  value       = { for k, v in module.vpc : k => v.project_id }
  description = "Map of VPC project IDs"
}

output "network_ids" {
  value       = { for k, v in module.vpc : k => v.network_id }
  description = "Map of VPC network IDs"
}
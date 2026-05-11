output "name" {
  description = "The name of the private endpoint."
  value       = azapi_resource.this.name
}

output "private_dns_zone_group_id" {
  description = "The resource ID of the private DNS zone group (if managed by this module), otherwise `null`."
  value       = length(azapi_resource.private_dns_zone_group) > 0 ? azapi_resource.private_dns_zone_group[0].id : null
}

output "resource_id" {
  description = "The resource ID of the private endpoint."
  value       = azapi_resource.this.id
}

output "role_assignments" {
  description = "Map of role assignment resources created at the private endpoint scope, keyed by the input map key."
  value       = module.role_assignments.role_assignments
}

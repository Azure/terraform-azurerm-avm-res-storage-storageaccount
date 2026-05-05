output "name" {
  description = "The name of the private endpoint."
  value       = azapi_resource.this.name
}

output "private_dns_zone_group" {
  description = "The private DNS zone group resource (if managed by this module)."
  value       = length(azapi_resource.private_dns_zone_group) > 0 ? azapi_resource.private_dns_zone_group[0] : null
}

output "resource" {
  description = "The full private endpoint azapi_resource."
  value       = azapi_resource.this
}

output "resource_id" {
  description = "The resource ID of the private endpoint."
  value       = azapi_resource.this.id
}

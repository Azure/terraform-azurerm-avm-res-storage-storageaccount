output "id" {
  description = "The resource ID of the container."
  value       = azapi_resource.this.id
}

output "name" {
  description = "The name of the container."
  value       = azapi_resource.this.name
}

output "resource" {
  description = "The full container azapi_resource."
  value       = azapi_resource.this
}

output "role_assignments" {
  description = "Map of role assignments created at the container scope."
  value       = module.role_assignments.role_assignments
}

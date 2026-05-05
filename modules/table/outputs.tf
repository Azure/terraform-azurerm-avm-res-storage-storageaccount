output "id" {
  description = "The resource ID of the table."
  value       = azapi_resource.this.id
}

output "name" {
  description = "The name of the table."
  value       = azapi_resource.this.name
}

output "resource" {
  description = "The full table azapi_resource."
  value       = azapi_resource.this
}

output "role_assignments" {
  description = "Map of role assignments created at the table scope."
  value       = module.role_assignments.role_assignments
}

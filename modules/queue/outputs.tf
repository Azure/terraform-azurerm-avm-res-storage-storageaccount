output "id" {
  description = "The resource ID of the queue."
  value       = azapi_resource.this.id
}

output "name" {
  description = "The name of the queue."
  value       = azapi_resource.this.name
}

output "resource" {
  description = "The full queue azapi_resource."
  value       = azapi_resource.this
}

output "role_assignments" {
  description = "Map of role assignments created at the queue scope."
  value       = module.role_assignments.role_assignments
}

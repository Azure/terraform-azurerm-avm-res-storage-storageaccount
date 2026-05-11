output "name" {
  description = "The name of the file share."
  value       = azapi_resource.this.name
}

output "resource" {
  description = "The full share azapi_resource."
  value       = azapi_resource.this
}

output "resource_id" {
  description = "The resource ID of the file share."
  value       = azapi_resource.this.id
}

output "role_assignments" {
  description = "Map of role assignment resources created at the share scope, keyed by the input map key."
  value       = module.role_assignments.role_assignments
}

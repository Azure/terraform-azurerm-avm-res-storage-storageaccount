output "name" {
  description = "The name of the table."
  value       = azapi_resource.this.name
}

output "resource" {
  description = "The full table azapi_resource."
  value       = azapi_resource.this
}

output "resource_id" {
  description = "The resource ID of the table."
  value       = azapi_resource.this.id
}

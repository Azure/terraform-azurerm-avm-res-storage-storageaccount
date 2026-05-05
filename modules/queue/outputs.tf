output "name" {
  description = "The name of the queue."
  value       = azapi_resource.this.name
}

output "resource" {
  description = "The full queue azapi_resource."
  value       = azapi_resource.this
}

output "resource_id" {
  description = "The resource ID of the queue."
  value       = azapi_resource.this.id
}

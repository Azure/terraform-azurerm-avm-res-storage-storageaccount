output "name" {
  description = "The name of the container."
  value       = azapi_resource.this.name
}

output "resource" {
  description = "The full container azapi_resource."
  value       = azapi_resource.this
}

output "resource_id" {
  description = "The resource ID of the container."
  value       = azapi_resource.this.id
}

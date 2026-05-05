output "name" {
  description = "The name of the filesystem."
  value       = azapi_resource.this.name
}

output "resource" {
  description = "The full filesystem azapi_resource."
  value       = azapi_resource.this
}

output "resource_id" {
  description = "The resource ID of the underlying container backing the filesystem."
  value       = azapi_resource.this.id
}

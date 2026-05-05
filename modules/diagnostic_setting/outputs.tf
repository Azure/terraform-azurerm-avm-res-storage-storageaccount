output "id" {
  description = "The resource ID of the diagnostic setting."
  value       = azapi_resource.this.id
}

output "name" {
  description = "The name of the diagnostic setting."
  value       = azapi_resource.this.name
}

output "resource" {
  description = "The full diagnostic setting azapi_resource."
  value       = azapi_resource.this
}

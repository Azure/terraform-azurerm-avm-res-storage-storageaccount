output "resource" {
  description = "The full management policy azapi_resource."
  value       = azapi_resource.this
}

output "resource_id" {
  description = "The resource ID of the management policy."
  value       = azapi_resource.this.id
}

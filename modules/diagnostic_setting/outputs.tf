output "names" {
  description = "Map from input key to the generated diagnostic setting name."
  value       = { for k, r in azapi_resource.this : k => r.name }
}

output "resource_ids" {
  description = "Map from input key to the resource ID of the diagnostic setting."
  value       = { for k, r in azapi_resource.this : k => r.id }
}

output "resources" {
  description = "Map from input key to the full diagnostic setting azapi_resource."
  value       = azapi_resource.this
}

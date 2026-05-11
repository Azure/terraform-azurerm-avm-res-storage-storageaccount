output "resource_id" {
  description = "The resource ID of the patched blobServices/default."
  value       = azapi_update_resource.this.id
}

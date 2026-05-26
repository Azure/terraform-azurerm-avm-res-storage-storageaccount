output "resource" {
  description = "The full azapi_update_resource object for the table service."
  value       = azapi_update_resource.this
}

output "resource_id" {
  description = "The resource ID of the table service."
  value       = "${var.storage_account_id}/tableServices/default"
}

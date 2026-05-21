output "resource" {
  description = "The full azapi_update_resource object for the queue service."
  value       = azapi_update_resource.this
}

output "resource_id" {
  description = "The resource ID of the queue service."
  value       = "${var.storage_account_id}/queueServices/default"
}

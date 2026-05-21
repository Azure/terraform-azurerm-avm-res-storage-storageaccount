output "resource_id" {
  description = "The resource ID of the blob service."
  value       = "${var.storage_account_id}/blobServices/default"
}

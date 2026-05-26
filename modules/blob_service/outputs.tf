output "resource" {
  description = "The full azapi_update_resource object for the blob service."
  value       = azapi_update_resource.this
}

output "resource_id" {
  description = "The resource ID of the blob service."
  value       = azapi_update_resource.this.id
}

output "restore_policy_last_enabled_time" {
  description = "Deprecated in favour of restore_policy_min_restore_time. The last time the restore policy was enabled."
  value       = try(azapi_update_resource.this.output.properties.restorePolicy.lastEnabledTime, null)
}

output "restore_policy_min_restore_time" {
  description = "The minimum date and time from which the restore can be started."
  value       = try(azapi_update_resource.this.output.properties.restorePolicy.minRestoreTime, null)
}

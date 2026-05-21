resource "azapi_update_resource" "this" {
  resource_id = "${var.storage_account_id}/blobServices/default"
  type        = var.resource_type
  body = {
    properties = {
      cors = var.blob_properties.cors_rules == null ? null : {
        corsRules = [for r in var.blob_properties.cors_rules : {
          allowedHeaders  = r.allowed_headers
          allowedMethods  = r.allowed_methods
          allowedOrigins  = r.allowed_origins
          exposedHeaders  = r.exposed_headers
          maxAgeInSeconds = r.max_age_in_seconds
        }]
      }
      deleteRetentionPolicy = var.blob_properties.delete_retention_policy == null ? null : {
        enabled              = true
        days                 = var.blob_properties.delete_retention_policy.days
        allowPermanentDelete = var.blob_properties.delete_retention_policy.permanent_delete_enabled
      }
      containerDeleteRetentionPolicy = var.blob_properties.container_delete_retention_policy == null ? null : {
        enabled = true
        days    = var.blob_properties.container_delete_retention_policy.days
      }
      changeFeed = (var.blob_properties.change_feed_enabled == null && var.blob_properties.change_feed_retention_in_days == null) ? null : {
        enabled         = var.blob_properties.change_feed_enabled
        retentionInDays = var.blob_properties.change_feed_retention_in_days
      }
      defaultServiceVersion = var.blob_properties.default_service_version
      lastAccessTimeTrackingPolicy = var.blob_properties.last_access_time_tracking_enabled == null ? null : {
        enable                    = var.blob_properties.last_access_time_tracking_enabled
        name                      = "AccessTimeTracking"
        trackingGranularityInDays = 1
        blobType                  = ["blockBlob"]
      }
      restorePolicy = var.blob_properties.restore_policy_days == null ? null : {
        enabled = true
        days    = var.blob_properties.restore_policy_days
      }
      isVersioningEnabled = var.blob_properties.versioning_enabled
    }
  }
  read_headers   = local.tracing_headers
  retry          = var.retry
  update_headers = local.tracing_headers

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]

    content {
      create = timeouts.value.create
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }
}

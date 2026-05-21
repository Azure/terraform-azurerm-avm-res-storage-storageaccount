resource "azapi_update_resource" "this" {
  resource_id = "${var.storage_account_id}/blobServices/default"
  type        = var.resource_type
  body = {
    properties = {
      automaticSnapshotPolicyEnabled = var.blob_properties.automatic_snapshot_policy_enabled
      changeFeed = var.blob_properties.change_feed == null ? null : {
        enabled         = var.blob_properties.change_feed.enabled
        retentionInDays = var.blob_properties.change_feed.retention_in_days
      }
      containerDeleteRetentionPolicy = var.blob_properties.container_delete_retention_policy == null ? null : {
        allowPermanentDelete = var.blob_properties.container_delete_retention_policy.allow_permanent_delete
        days                 = var.blob_properties.container_delete_retention_policy.days
        enabled              = var.blob_properties.container_delete_retention_policy.enabled
      }
      cors = var.blob_properties.cors_rules == null ? null : {
        corsRules = [for r in var.blob_properties.cors_rules : {
          allowedHeaders  = r.allowed_headers
          allowedMethods  = r.allowed_methods
          allowedOrigins  = r.allowed_origins
          exposedHeaders  = r.exposed_headers
          maxAgeInSeconds = r.max_age_in_seconds
        }]
      }
      defaultServiceVersion = var.blob_properties.default_service_version
      deleteRetentionPolicy = var.blob_properties.delete_retention_policy == null ? null : {
        allowPermanentDelete = var.blob_properties.delete_retention_policy.allow_permanent_delete
        days                 = var.blob_properties.delete_retention_policy.days
        enabled              = var.blob_properties.delete_retention_policy.enabled
      }
      isVersioningEnabled = var.blob_properties.versioning_enabled
      lastAccessTimeTrackingPolicy = var.blob_properties.last_access_time_tracking_policy == null ? null : {
        blobType                  = var.blob_properties.last_access_time_tracking_policy.blob_type
        enable                    = var.blob_properties.last_access_time_tracking_policy.enable
        name                      = var.blob_properties.last_access_time_tracking_policy.name
        trackingGranularityInDays = var.blob_properties.last_access_time_tracking_policy.tracking_granularity_in_days
      }
      restorePolicy = var.blob_properties.restore_policy == null ? null : {
        days    = var.blob_properties.restore_policy.days
        enabled = var.blob_properties.restore_policy.enabled
      }
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

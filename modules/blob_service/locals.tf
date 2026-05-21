locals {
  resource_body = {
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
  tracing_headers = var.tracing_tags_header == null ? null : { "User-Agent" = var.tracing_tags_header }
}

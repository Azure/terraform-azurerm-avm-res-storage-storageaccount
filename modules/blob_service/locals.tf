locals {
  resource_body = {
    properties = merge(
      var.blob_properties.automatic_snapshot_policy_enabled == null ? {} : {
        automaticSnapshotPolicyEnabled = var.blob_properties.automatic_snapshot_policy_enabled
      },
      var.blob_properties.change_feed == null ? {} : {
        changeFeed = merge(
          var.blob_properties.change_feed.enabled == null ? {} : {
            enabled = var.blob_properties.change_feed.enabled
          },
          var.blob_properties.change_feed.retention_in_days == null ? {} : {
            retentionInDays = var.blob_properties.change_feed.retention_in_days
          },
        )
      },
      var.blob_properties.container_delete_retention_policy == null ? {} : {
        containerDeleteRetentionPolicy = merge(
          var.blob_properties.container_delete_retention_policy.allow_permanent_delete == null ? {} : {
            allowPermanentDelete = var.blob_properties.container_delete_retention_policy.allow_permanent_delete
          },
          var.blob_properties.container_delete_retention_policy.days == null ? {} : {
            days = var.blob_properties.container_delete_retention_policy.days
          },
          var.blob_properties.container_delete_retention_policy.enabled == null ? {} : {
            enabled = var.blob_properties.container_delete_retention_policy.enabled
          },
        )
      },
      var.blob_properties.cors_rules == null ? {} : {
        cors = {
          corsRules = [for r in var.blob_properties.cors_rules : {
            allowedHeaders  = r.allowed_headers
            allowedMethods  = r.allowed_methods
            allowedOrigins  = r.allowed_origins
            exposedHeaders  = r.exposed_headers
            maxAgeInSeconds = r.max_age_in_seconds
          }]
        }
      },
      var.blob_properties.default_service_version == null ? {} : {
        defaultServiceVersion = var.blob_properties.default_service_version
      },
      var.blob_properties.delete_retention_policy == null ? {} : {
        deleteRetentionPolicy = merge(
          var.blob_properties.delete_retention_policy.allow_permanent_delete == null ? {} : {
            allowPermanentDelete = var.blob_properties.delete_retention_policy.allow_permanent_delete
          },
          var.blob_properties.delete_retention_policy.days == null ? {} : {
            days = var.blob_properties.delete_retention_policy.days
          },
          var.blob_properties.delete_retention_policy.enabled == null ? {} : {
            enabled = var.blob_properties.delete_retention_policy.enabled
          },
        )
      },
      var.blob_properties.versioning_enabled == null ? {} : {
        isVersioningEnabled = var.blob_properties.versioning_enabled
      },
      var.blob_properties.last_access_time_tracking_policy == null ? {} : {
        lastAccessTimeTrackingPolicy = merge(
          {
            enable = var.blob_properties.last_access_time_tracking_policy.enable
          },
          var.blob_properties.last_access_time_tracking_policy.blob_type == null ? {} : {
            blobType = var.blob_properties.last_access_time_tracking_policy.blob_type
          },
          var.blob_properties.last_access_time_tracking_policy.name == null ? {} : {
            name = var.blob_properties.last_access_time_tracking_policy.name
          },
          var.blob_properties.last_access_time_tracking_policy.tracking_granularity_in_days == null ? {} : {
            trackingGranularityInDays = var.blob_properties.last_access_time_tracking_policy.tracking_granularity_in_days
          },
        )
      },
      var.blob_properties.restore_policy == null ? {} : {
        restorePolicy = merge(
          {
            enabled = var.blob_properties.restore_policy.enabled
          },
          var.blob_properties.restore_policy.days == null ? {} : {
            days = var.blob_properties.restore_policy.days
          },
        )
      },
    )
  }
  tracing_headers = var.tracing_tags_header == null ? null : { "User-Agent" = var.tracing_tags_header }
}

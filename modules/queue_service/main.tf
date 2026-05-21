resource "azapi_update_resource" "this" {
  resource_id = "${var.storage_account_id}/queueServices/default"
  type        = var.resource_type
  body = {
    properties = {
      cors = var.queue_properties.cors_rules == null ? null : {
        corsRules = [for r in var.queue_properties.cors_rules : {
          allowedHeaders  = r.allowed_headers
          allowedMethods  = r.allowed_methods
          allowedOrigins  = r.allowed_origins
          exposedHeaders  = r.exposed_headers
          maxAgeInSeconds = r.max_age_in_seconds
        }]
      }
      logging = var.queue_properties.logging == null ? null : {
        delete  = var.queue_properties.logging.delete
        read    = var.queue_properties.logging.read
        write   = var.queue_properties.logging.write
        version = var.queue_properties.logging.version
        retentionPolicy = {
          enabled = var.queue_properties.logging.retention_policy_days != null
          days    = var.queue_properties.logging.retention_policy_days
        }
      }
      hourMetrics = var.queue_properties.hour_metrics == null ? null : {
        enabled     = var.queue_properties.hour_metrics.enabled
        includeAPIs = var.queue_properties.hour_metrics.include_apis
        version     = var.queue_properties.hour_metrics.version
        retentionPolicy = {
          enabled = var.queue_properties.hour_metrics.retention_policy_days != null
          days    = var.queue_properties.hour_metrics.retention_policy_days
        }
      }
      minuteMetrics = var.queue_properties.minute_metrics == null ? null : {
        enabled     = var.queue_properties.minute_metrics.enabled
        includeAPIs = var.queue_properties.minute_metrics.include_apis
        version     = var.queue_properties.minute_metrics.version
        retentionPolicy = {
          enabled = var.queue_properties.minute_metrics.retention_policy_days != null
          days    = var.queue_properties.minute_metrics.retention_policy_days
        }
      }
    }
  }
  create_headers = local.tracing_headers
  read_headers   = local.tracing_headers
  update_headers = local.tracing_headers
  retry          = var.retry

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]
    content {
      create = timeouts.value.create
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }
}

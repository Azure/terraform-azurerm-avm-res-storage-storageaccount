locals {
  tracing_headers = var.tracing_tags_header == null ? null : { "User-Agent" = var.tracing_tags_header }

  resource_body = {
    properties = {
      cors = var.queue_properties.cors_rules == null ? null : {
        corsRules = [for r in var.queue_properties.cors_rules : {
          allowedHeaders  = r.allowed_headers == null ? null : [for h in r.allowed_headers : h]
          allowedMethods  = r.allowed_methods == null ? null : [for m in r.allowed_methods : m]
          allowedOrigins  = r.allowed_origins == null ? null : [for o in r.allowed_origins : o]
          exposedHeaders  = r.exposed_headers == null ? null : [for h in r.exposed_headers : h]
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
}

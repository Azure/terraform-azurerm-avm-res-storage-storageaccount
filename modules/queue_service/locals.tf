locals {
  resource_body = {
    properties = merge(
      var.queue_properties.cors_rules == null ? {} : {
        cors = {
          corsRules = [for r in var.queue_properties.cors_rules : {
            allowedHeaders  = r.allowed_headers
            allowedMethods  = r.allowed_methods
            allowedOrigins  = r.allowed_origins
            exposedHeaders  = r.exposed_headers
            maxAgeInSeconds = r.max_age_in_seconds
          }]
        }
      },
      var.queue_properties.logging == null ? {} : {
        logging = merge(
          {
            delete  = var.queue_properties.logging.delete
            read    = var.queue_properties.logging.read
            version = var.queue_properties.logging.version
            write   = var.queue_properties.logging.write
          },
          {
            retentionPolicy = merge(
              {
                enabled = var.queue_properties.logging.retention_policy_days != null
              },
              var.queue_properties.logging.retention_policy_days == null ? {} : {
                days = var.queue_properties.logging.retention_policy_days
              },
            )
          },
        )
      },
      var.queue_properties.hour_metrics == null ? {} : {
        hourMetrics = merge(
          {
            enabled = var.queue_properties.hour_metrics.enabled
            version = var.queue_properties.hour_metrics.version
          },
          var.queue_properties.hour_metrics.include_apis == null ? {} : {
            includeAPIs = var.queue_properties.hour_metrics.include_apis
          },
          {
            retentionPolicy = merge(
              {
                enabled = var.queue_properties.hour_metrics.retention_policy_days != null
              },
              var.queue_properties.hour_metrics.retention_policy_days == null ? {} : {
                days = var.queue_properties.hour_metrics.retention_policy_days
              },
            )
          },
        )
      },
      var.queue_properties.minute_metrics == null ? {} : {
        minuteMetrics = merge(
          {
            enabled = var.queue_properties.minute_metrics.enabled
            version = var.queue_properties.minute_metrics.version
          },
          var.queue_properties.minute_metrics.include_apis == null ? {} : {
            includeAPIs = var.queue_properties.minute_metrics.include_apis
          },
          {
            retentionPolicy = merge(
              {
                enabled = var.queue_properties.minute_metrics.retention_policy_days != null
              },
              var.queue_properties.minute_metrics.retention_policy_days == null ? {} : {
                days = var.queue_properties.minute_metrics.retention_policy_days
              },
            )
          },
        )
      },
    )
  }
  tracing_headers = var.tracing_tags_header == null ? null : { "User-Agent" = var.tracing_tags_header }
}

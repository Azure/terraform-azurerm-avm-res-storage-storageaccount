locals {
  resource_body = {
    properties = merge(
      var.table_properties.cors_rules == null ? {} : {
        cors = {
          corsRules = [for r in var.table_properties.cors_rules : {
            allowedHeaders  = r.allowed_headers
            allowedMethods  = r.allowed_methods
            allowedOrigins  = r.allowed_origins
            exposedHeaders  = r.exposed_headers
            maxAgeInSeconds = r.max_age_in_seconds
          }]
        }
      },
      var.table_properties.logging == null ? {} : {
        logging = merge(
          {
            delete  = var.table_properties.logging.delete
            read    = var.table_properties.logging.read
            version = var.table_properties.logging.version
            write   = var.table_properties.logging.write
          },
          {
            retentionPolicy = merge(
              {
                enabled = var.table_properties.logging.retention_policy_days != null
              },
              var.table_properties.logging.retention_policy_days == null ? {} : {
                days = var.table_properties.logging.retention_policy_days
              },
            )
          },
        )
      },
      var.table_properties.hour_metrics == null ? {} : {
        hourMetrics = merge(
          {
            enabled = var.table_properties.hour_metrics.enabled
            version = var.table_properties.hour_metrics.version
          },
          var.table_properties.hour_metrics.include_apis == null ? {} : {
            includeAPIs = var.table_properties.hour_metrics.include_apis
          },
          {
            retentionPolicy = merge(
              {
                enabled = var.table_properties.hour_metrics.retention_policy_days != null
              },
              var.table_properties.hour_metrics.retention_policy_days == null ? {} : {
                days = var.table_properties.hour_metrics.retention_policy_days
              },
            )
          },
        )
      },
      var.table_properties.minute_metrics == null ? {} : {
        minuteMetrics = merge(
          {
            enabled = var.table_properties.minute_metrics.enabled
            version = var.table_properties.minute_metrics.version
          },
          var.table_properties.minute_metrics.include_apis == null ? {} : {
            includeAPIs = var.table_properties.minute_metrics.include_apis
          },
          {
            retentionPolicy = merge(
              {
                enabled = var.table_properties.minute_metrics.retention_policy_days != null
              },
              var.table_properties.minute_metrics.retention_policy_days == null ? {} : {
                days = var.table_properties.minute_metrics.retention_policy_days
              },
            )
          },
        )
      },
    )
  }
  tracing_headers = var.tracing_tags_header == null ? null : { "User-Agent" = var.tracing_tags_header }
}

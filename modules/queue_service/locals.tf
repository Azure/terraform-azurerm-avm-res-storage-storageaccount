locals {
  resource_body = {
    # Queue service logging and metrics are intentionally excluded here because
    # the ARM queueServices/default PATCH path does not persist them reliably.
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
    )
  }
  tracing_headers = var.tracing_tags_header == null ? null : { "User-Agent" = var.tracing_tags_header }
}

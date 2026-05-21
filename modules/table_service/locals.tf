locals {
  resource_body = {
    # Table service logging and metrics are intentionally excluded here because
    # the ARM tableServices/default PATCH path does not persist them reliably.
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
    )
  }
  tracing_headers = var.tracing_tags_header == null ? null : { "User-Agent" = var.tracing_tags_header }
}

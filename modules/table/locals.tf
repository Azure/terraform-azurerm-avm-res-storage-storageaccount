locals {
  signed_identifiers_body = var.signed_identifiers == null ? [] : [
    for si in var.signed_identifiers : {
      id = si.id
      accessPolicy = si.access_policy == null ? null : {
        expiryTime = si.access_policy.expiry_time
        permission = si.access_policy.permission
        startTime  = si.access_policy.start_time
      }
    }
  ]
  tracing_headers = var.tracing_tags_header == null ? null : { "User-Agent" = var.tracing_tags_header }
}

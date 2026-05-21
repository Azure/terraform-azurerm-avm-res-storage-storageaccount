variable "blob_properties" {
  type = object({
    cors_rules = optional(list(object({
      allowed_headers    = list(string)
      allowed_methods    = list(string)
      allowed_origins    = list(string)
      exposed_headers    = list(string)
      max_age_in_seconds = number
    })))
    delete_retention_policy = optional(object({
      days                     = optional(number, 7)
      permanent_delete_enabled = optional(bool, false)
    }))
    container_delete_retention_policy = optional(object({
      days = optional(number, 7)
    }))
    change_feed_enabled               = optional(bool)
    change_feed_retention_in_days     = optional(number)
    default_service_version           = optional(string)
    last_access_time_tracking_enabled = optional(bool)
    restore_policy_days               = optional(number)
    versioning_enabled                = optional(bool)
  })
  default     = null
  description = <<-EOT
Blob service-level settings for the storage account. Defaults to `null` (Azure platform defaults).

- `cors_rules` - (Optional) A list of CORS rules. Each entry supports:
  - `allowed_headers` - (Required) A list of headers allowed in cross-origin requests.
  - `allowed_methods` - (Required) A list of HTTP methods allowed. Valid values include `DELETE`, `GET`, `HEAD`, `MERGE`, `POST`, `OPTIONS`, `PUT` or `PATCH`.
  - `allowed_origins` - (Required) A list of origin domains allowed in cross-origin requests.
  - `exposed_headers` - (Required) A list of response headers exposed to CORS clients.
  - `max_age_in_seconds` - (Required) The number of seconds the browser should cache a preflight response.
- `delete_retention_policy` - (Optional) Blob soft-delete retention policy. Defaults to `null`.
  - `days` - (Optional) Number of days to retain deleted blobs. Between 1 and 365. Defaults to `7`.
  - `permanent_delete_enabled` - (Optional) Allow permanent delete of versioned blobs. Defaults to `false`.
- `container_delete_retention_policy` - (Optional) Container soft-delete retention policy. Defaults to `null`.
  - `days` - (Optional) Number of days to retain deleted containers. Between 1 and 365. Defaults to `7`.
- `change_feed_enabled` - (Optional) Enable the blob change feed. Defaults to `null`.
- `change_feed_retention_in_days` - (Optional) Retention period for the change feed in days. Defaults to `null`.
- `default_service_version` - (Optional) The API version to use for requests to the Blob service if no version is specified. Defaults to `null`.
- `last_access_time_tracking_enabled` - (Optional) Enable last-access time tracking. Defaults to `null`.
- `restore_policy_days` - (Optional) Point-in-time restore retention in days. Requires `versioning_enabled`, `change_feed_enabled`, and `delete_retention_policy`. Defaults to `null`.
- `versioning_enabled` - (Optional) Enable blob versioning. Defaults to `null`.
EOT
}

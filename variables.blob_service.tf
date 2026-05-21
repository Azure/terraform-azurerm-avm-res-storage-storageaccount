variable "blob_properties" {
  type = object({
    automatic_snapshot_policy_enabled = optional(bool)
    change_feed = optional(object({
      enabled           = optional(bool)
      retention_in_days = optional(number)
    }))
    container_delete_retention_policy = optional(object({
      allow_permanent_delete = optional(bool)
      days                   = optional(number)
      enabled                = optional(bool)
    }))
    cors_rules = optional(list(object({
      allowed_headers    = list(string)
      allowed_methods    = list(string)
      allowed_origins    = list(string)
      exposed_headers    = list(string)
      max_age_in_seconds = number
    })))
    default_service_version = optional(string)
    delete_retention_policy = optional(object({
      allow_permanent_delete = optional(bool)
      days                   = optional(number)
      enabled                = optional(bool)
    }))
    last_access_time_tracking_policy = optional(object({
      blob_type                    = optional(list(string))
      enable                       = bool
      name                         = optional(string)
      tracking_granularity_in_days = optional(number)
    }))
    restore_policy = optional(object({
      days    = optional(number)
      enabled = bool
    }))
    versioning_enabled = optional(bool)
  })
  default     = null
  description = <<-EOT
Blob service-level settings for the storage account. Defaults to `null` (Azure platform defaults).

- `automatic_snapshot_policy_enabled` - (Optional) Deprecated; use `versioning_enabled` instead. Defaults to `null`.
- `change_feed` - (Optional) Blob change feed settings. Defaults to `null`.
  - `enabled` - (Optional) Enable the blob change feed. Defaults to `null`.
  - `retention_in_days` - (Optional) Retention period for the change feed in days (1–146000). `null` means infinite. Defaults to `null`.
- `container_delete_retention_policy` - (Optional) Container soft-delete retention policy. Defaults to `null`.
  - `allow_permanent_delete` - (Optional) Allow permanent delete of soft-deleted containers. Defaults to `null`.
  - `days` - (Optional) Number of days to retain deleted containers (1–365). Defaults to `null`.
  - `enabled` - (Optional) Enable container soft-delete. Defaults to `null`.
- `cors_rules` - (Optional) A list of CORS rules (maximum 5). Each entry supports:
  - `allowed_headers` - (Required) A list of headers allowed in cross-origin requests.
  - `allowed_methods` - (Required) A list of HTTP methods allowed. Valid values: `DELETE`, `GET`, `HEAD`, `MERGE`, `POST`, `OPTIONS`, `PUT`, `PATCH`.
  - `allowed_origins` - (Required) A list of origin domains allowed in cross-origin requests.
  - `exposed_headers` - (Required) A list of response headers exposed to CORS clients.
  - `max_age_in_seconds` - (Required) The number of seconds the browser should cache a preflight response.
- `default_service_version` - (Optional) Default Blob service API version for requests without a version. Defaults to `null`.
- `delete_retention_policy` - (Optional) Blob soft-delete retention policy. Defaults to `null`.
  - `allow_permanent_delete` - (Optional) Allow permanent delete of soft-deleted blobs and snapshots. Cannot be used with `restore_policy`. Defaults to `null`.
  - `days` - (Optional) Number of days to retain deleted blobs (1–365). Defaults to `null`.
  - `enabled` - (Optional) Enable blob soft-delete. Defaults to `null`.
- `last_access_time_tracking_policy` - (Optional) Last access time tracking policy. Defaults to `null`.
  - `blob_type` - (Optional) Blob types to track. Only `["blockBlob"]` is supported (read-only). Defaults to `null`.
  - `enable` - (Required) Enable last access time tracking.
  - `name` - (Optional) Policy name. Must be `"AccessTimeTracking"` (read-only). Defaults to `null`.
  - `tracking_granularity_in_days` - (Optional) Granularity in days (read-only, always `1`). Defaults to `null`.
- `restore_policy` - (Optional) Point-in-time restore policy. Requires `versioning_enabled`, `change_feed.enabled`, and `delete_retention_policy.enabled`. Defaults to `null`.
  - `days` - (Optional) Restore retention in days. Must be less than `delete_retention_policy.days`. Defaults to `null`.
  - `enabled` - (Required) Enable point-in-time restore.
- `versioning_enabled` - (Optional) Enable blob versioning. Defaults to `null`.
EOT

  validation {
    condition = var.blob_properties == null || var.blob_properties.change_feed == null || var.blob_properties.change_feed.retention_in_days == null || (
      var.blob_properties.change_feed.retention_in_days >= 1 && var.blob_properties.change_feed.retention_in_days <= 146000
    )
    error_message = "blob_properties.change_feed.retention_in_days must be between 1 and 146000."
  }
  validation {
    condition = var.blob_properties == null || var.blob_properties.delete_retention_policy == null || var.blob_properties.delete_retention_policy.days == null || (
      var.blob_properties.delete_retention_policy.days >= 1 && var.blob_properties.delete_retention_policy.days <= 365
    )
    error_message = "blob_properties.delete_retention_policy.days must be between 1 and 365."
  }
  validation {
    condition = var.blob_properties == null || var.blob_properties.container_delete_retention_policy == null || var.blob_properties.container_delete_retention_policy.days == null || (
      var.blob_properties.container_delete_retention_policy.days >= 1 && var.blob_properties.container_delete_retention_policy.days <= 365
    )
    error_message = "blob_properties.container_delete_retention_policy.days must be between 1 and 365."
  }
  validation {
    condition = var.blob_properties == null || var.blob_properties.restore_policy == null || var.blob_properties.restore_policy.days == null || (
      var.blob_properties.restore_policy.days >= 1 && var.blob_properties.restore_policy.days <= 365
    )
    error_message = "blob_properties.restore_policy.days must be between 1 and 365."
  }
}

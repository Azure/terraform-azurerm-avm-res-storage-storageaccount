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
  description = "(Required) Blob service-level settings to apply. This variable is required because the module is only instantiated when `var.blob_properties` is non-null."
  nullable    = false

  validation {
    condition = (
      var.blob_properties.change_feed == null ||
      var.blob_properties.change_feed.retention_in_days == null ||
      var.blob_properties.change_feed.retention_in_days >= 1
    )
    error_message = "blob_properties.change_feed.retention_in_days must be greater than or equal to 1."
  }
  validation {
    condition = (
      var.blob_properties.change_feed == null ||
      var.blob_properties.change_feed.retention_in_days == null ||
      var.blob_properties.change_feed.retention_in_days <= 146000
    )
    error_message = "blob_properties.change_feed.retention_in_days must be less than or equal to 146000."
  }
  validation {
    condition = (
      var.blob_properties.delete_retention_policy == null ||
      var.blob_properties.delete_retention_policy.days == null ||
      var.blob_properties.delete_retention_policy.days >= 1
    )
    error_message = "blob_properties.delete_retention_policy.days must be greater than or equal to 1."
  }
  validation {
    condition = (
      var.blob_properties.delete_retention_policy == null ||
      var.blob_properties.delete_retention_policy.days == null ||
      var.blob_properties.delete_retention_policy.days <= 365
    )
    error_message = "blob_properties.delete_retention_policy.days must be less than or equal to 365."
  }
  validation {
    condition = (
      var.blob_properties.container_delete_retention_policy == null ||
      var.blob_properties.container_delete_retention_policy.days == null ||
      var.blob_properties.container_delete_retention_policy.days >= 1
    )
    error_message = "blob_properties.container_delete_retention_policy.days must be greater than or equal to 1."
  }
  validation {
    condition = (
      var.blob_properties.container_delete_retention_policy == null ||
      var.blob_properties.container_delete_retention_policy.days == null ||
      var.blob_properties.container_delete_retention_policy.days <= 365
    )
    error_message = "blob_properties.container_delete_retention_policy.days must be less than or equal to 365."
  }
  validation {
    condition = (
      var.blob_properties.restore_policy == null ||
      var.blob_properties.restore_policy.days == null ||
      var.blob_properties.restore_policy.days >= 1
    )
    error_message = "blob_properties.restore_policy.days must be greater than or equal to 1."
  }
  validation {
    condition = (
      var.blob_properties.restore_policy == null ||
      var.blob_properties.restore_policy.days == null ||
      var.blob_properties.restore_policy.days <= 365
    )
    error_message = "blob_properties.restore_policy.days must be less than or equal to 365."
  }
  validation {
    condition = (
      var.blob_properties.restore_policy == null ||
      var.blob_properties.restore_policy.days == null ||
      var.blob_properties.delete_retention_policy == null ||
      var.blob_properties.delete_retention_policy.days == null ||
      var.blob_properties.restore_policy.days < var.blob_properties.delete_retention_policy.days
    )
    error_message = "blob_properties.restore_policy.days must be less than blob_properties.delete_retention_policy.days."
  }
  validation {
    condition = (
      var.blob_properties.last_access_time_tracking_policy == null ||
      var.blob_properties.last_access_time_tracking_policy.name == null ||
      contains(["AccessTimeTracking"], var.blob_properties.last_access_time_tracking_policy.name)
    )
    error_message = "blob_properties.last_access_time_tracking_policy.name must be \"AccessTimeTracking\"."
  }
}

variable "storage_account_id" {
  type        = string
  description = "(Required) The full resource ID of the parent storage account."
  nullable    = false
}

variable "resource_type" {
  type        = string
  default     = "Microsoft.Storage/storageAccounts/blobServices@2025-06-01"
  description = "(Optional) Override the AzAPI `<provider>/<resource>@<api-version>` string used to patch the blob service. Defaults to the value tested with this module version."
  nullable    = false
}

variable "retry" {
  type = object({
    error_message_regex  = optional(list(string))
    interval_seconds     = optional(number)
    max_interval_seconds = optional(number)
  })
  default     = null
  description = <<-EOT
(Optional) Retry configuration applied to the AzAPI resource. Defaults to `null` (no custom retry).

- `error_message_regex` - (Optional) A list of regex patterns matching error messages that trigger a retry. Defaults to `null`.
- `interval_seconds` - (Optional) Initial interval between retries in seconds. Defaults to `null` (provider default).
- `max_interval_seconds` - (Optional) Maximum interval between retries in seconds. Defaults to `null` (provider default).
EOT
}

variable "timeouts" {
  type = object({
    create = optional(string)
    read   = optional(string)
    update = optional(string)
    delete = optional(string)
  })
  default     = null
  description = <<-EOT
(Optional) Per-operation timeouts applied to the AzAPI resource. Defaults to `null` (provider defaults). Each value is a Go duration string (e.g. `30m`, `1h`).

- `create` - (Optional) Timeout for create operations. Defaults to `null`.
- `read` - (Optional) Timeout for read operations. Defaults to `null`.
- `update` - (Optional) Timeout for update operations. Defaults to `null`.
- `delete` - (Optional) Timeout for delete operations. Defaults to `null`.
EOT
}

variable "tracing_tags_header" {
  type        = string
  default     = null
  description = "(Optional) User-Agent string injected into AzAPI request headers. Defaults to `null` (no custom header)."
}

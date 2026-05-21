variable "storage_account_id" {
  type        = string
  description = "(Required) The full resource ID of the parent storage account."
  nullable    = false
}

variable "queue_properties" {
  type = object({
    cors_rules = optional(list(object({
      allowed_headers    = list(string)
      allowed_methods    = list(string)
      allowed_origins    = list(string)
      exposed_headers    = list(string)
      max_age_in_seconds = number
    })))
    logging = optional(object({
      delete                = optional(bool, false)
      read                  = optional(bool, false)
      write                 = optional(bool, false)
      version               = optional(string, "1.0")
      retention_policy_days = optional(number)
    }))
    hour_metrics = optional(object({
      enabled               = optional(bool, true)
      include_apis          = optional(bool)
      retention_policy_days = optional(number)
      version               = optional(string, "1.0")
    }))
    minute_metrics = optional(object({
      enabled               = optional(bool, false)
      include_apis          = optional(bool)
      retention_policy_days = optional(number)
      version               = optional(string, "1.0")
    }))
  })
  description = "(Required) Queue service-level settings to apply to the storage account's queueServices/default sub-resource."
  nullable    = false

  validation {
    condition     = var.queue_properties.logging == null || var.queue_properties.logging.retention_policy_days == null || var.queue_properties.logging.retention_policy_days >= 1
    error_message = "queue_properties.logging.retention_policy_days must be greater than or equal to 1 when set."
  }
  validation {
    condition     = var.queue_properties.logging == null || var.queue_properties.logging.retention_policy_days == null || var.queue_properties.logging.retention_policy_days <= 365
    error_message = "queue_properties.logging.retention_policy_days must be less than or equal to 365 when set."
  }
  validation {
    condition     = var.queue_properties.hour_metrics == null || var.queue_properties.hour_metrics.retention_policy_days == null || var.queue_properties.hour_metrics.retention_policy_days >= 1
    error_message = "queue_properties.hour_metrics.retention_policy_days must be greater than or equal to 1 when set."
  }
  validation {
    condition     = var.queue_properties.hour_metrics == null || var.queue_properties.hour_metrics.retention_policy_days == null || var.queue_properties.hour_metrics.retention_policy_days <= 365
    error_message = "queue_properties.hour_metrics.retention_policy_days must be less than or equal to 365 when set."
  }
  validation {
    condition     = var.queue_properties.minute_metrics == null || var.queue_properties.minute_metrics.retention_policy_days == null || var.queue_properties.minute_metrics.retention_policy_days >= 1
    error_message = "queue_properties.minute_metrics.retention_policy_days must be greater than or equal to 1 when set."
  }
  validation {
    condition     = var.queue_properties.minute_metrics == null || var.queue_properties.minute_metrics.retention_policy_days == null || var.queue_properties.minute_metrics.retention_policy_days <= 365
    error_message = "queue_properties.minute_metrics.retention_policy_days must be less than or equal to 365 when set."
  }
}

variable "resource_type" {
  type        = string
  default     = "Microsoft.Storage/storageAccounts/queueServices@2025-06-01"
  description = "(Optional) Override the AzAPI `<provider>/<resource>@<api-version>` string used to patch the queue service. Defaults to the value tested with this module version."
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

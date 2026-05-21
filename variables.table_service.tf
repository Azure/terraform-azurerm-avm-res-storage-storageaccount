variable "table_properties" {
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
  default     = null
  description = <<-EOT
Table service-level settings for the storage account. Defaults to `null` (Azure platform defaults).

- `cors_rules` - (Optional) A list of CORS rules for the table service. Defaults to `null`. Each entry supports:
  - `allowed_headers` - (Required) A list of headers allowed in cross-origin requests.
  - `allowed_methods` - (Required) A list of HTTP methods allowed.
  - `allowed_origins` - (Required) A list of origin domains allowed.
  - `exposed_headers` - (Required) A list of response headers exposed to CORS clients.
  - `max_age_in_seconds` - (Required) Seconds the browser should cache a preflight response.
- `logging` - (Optional) Storage Analytics logging settings. Defaults to `null`.
  - `delete` - (Optional) Log delete operations. Defaults to `false`.
  - `read` - (Optional) Log read operations. Defaults to `false`.
  - `write` - (Optional) Log write operations. Defaults to `false`.
  - `version` - (Optional) Analytics version. Defaults to `1.0`.
  - `retention_policy_days` - (Optional) Number of days to retain logs (1–365). `null` means infinite retention.
- `hour_metrics` - (Optional) Hourly metrics settings. Defaults to `null`.
  - `enabled` - (Optional) Enable hourly metrics. Defaults to `true`.
  - `include_apis` - (Optional) Include API summaries in the metrics. Defaults to `null`.
  - `retention_policy_days` - (Optional) Retention in days (1–365). `null` means infinite retention.
  - `version` - (Optional) Analytics version. Defaults to `1.0`.
- `minute_metrics` - (Optional) Minute metrics settings. Defaults to `null`.
  - `enabled` - (Optional) Enable minute metrics. Defaults to `false`.
  - `include_apis` - (Optional) Include API summaries. Defaults to `null`.
  - `retention_policy_days` - (Optional) Retention in days (1–365). `null` means infinite retention.
  - `version` - (Optional) Analytics version. Defaults to `1.0`.
EOT

  validation {
    condition     = var.table_properties == null || var.table_properties.logging == null || var.table_properties.logging.retention_policy_days == null || var.table_properties.logging.retention_policy_days >= 1
    error_message = "table_properties.logging.retention_policy_days must be greater than or equal to 1 when set."
  }
  validation {
    condition     = var.table_properties == null || var.table_properties.logging == null || var.table_properties.logging.retention_policy_days == null || var.table_properties.logging.retention_policy_days <= 365
    error_message = "table_properties.logging.retention_policy_days must be less than or equal to 365 when set."
  }
  validation {
    condition     = var.table_properties == null || var.table_properties.hour_metrics == null || var.table_properties.hour_metrics.retention_policy_days == null || var.table_properties.hour_metrics.retention_policy_days >= 1
    error_message = "table_properties.hour_metrics.retention_policy_days must be greater than or equal to 1 when set."
  }
  validation {
    condition     = var.table_properties == null || var.table_properties.hour_metrics == null || var.table_properties.hour_metrics.retention_policy_days == null || var.table_properties.hour_metrics.retention_policy_days <= 365
    error_message = "table_properties.hour_metrics.retention_policy_days must be less than or equal to 365 when set."
  }
  validation {
    condition     = var.table_properties == null || var.table_properties.minute_metrics == null || var.table_properties.minute_metrics.retention_policy_days == null || var.table_properties.minute_metrics.retention_policy_days >= 1
    error_message = "table_properties.minute_metrics.retention_policy_days must be greater than or equal to 1 when set."
  }
  validation {
    condition     = var.table_properties == null || var.table_properties.minute_metrics == null || var.table_properties.minute_metrics.retention_policy_days == null || var.table_properties.minute_metrics.retention_policy_days <= 365
    error_message = "table_properties.minute_metrics.retention_policy_days must be less than or equal to 365 when set."
  }
}

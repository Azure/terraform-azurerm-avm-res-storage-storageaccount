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
  default     = null
  description = <<-EOT
Queue service-level settings for the storage account. Defaults to `null` (Azure platform defaults).

- `cors_rules` - (Optional) A list of CORS rules for the queue service. Defaults to `null`. Each entry supports:
  - `allowed_headers` - (Required) A list of headers allowed in cross-origin requests.
  - `allowed_methods` - (Required) A list of HTTP methods allowed.
  - `allowed_origins` - (Required) A list of origin domains allowed.
  - `exposed_headers` - (Required) A list of response headers exposed to CORS clients.
  - `max_age_in_seconds` - (Required) Seconds the browser should cache a preflight response.
- `logging` - (Optional) Storage analytics logging settings. Defaults to `null`.
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
    condition     = var.queue_properties == null || var.queue_properties.logging == null || var.queue_properties.logging.retention_policy_days == null || var.queue_properties.logging.retention_policy_days >= 1
    error_message = "queue_properties.logging.retention_policy_days must be greater than or equal to 1 when set."
  }
  validation {
    condition     = var.queue_properties == null || var.queue_properties.logging == null || var.queue_properties.logging.retention_policy_days == null || var.queue_properties.logging.retention_policy_days <= 365
    error_message = "queue_properties.logging.retention_policy_days must be less than or equal to 365 when set."
  }
  validation {
    condition     = var.queue_properties == null || var.queue_properties.hour_metrics == null || var.queue_properties.hour_metrics.retention_policy_days == null || var.queue_properties.hour_metrics.retention_policy_days >= 1
    error_message = "queue_properties.hour_metrics.retention_policy_days must be greater than or equal to 1 when set."
  }
  validation {
    condition     = var.queue_properties == null || var.queue_properties.hour_metrics == null || var.queue_properties.hour_metrics.retention_policy_days == null || var.queue_properties.hour_metrics.retention_policy_days <= 365
    error_message = "queue_properties.hour_metrics.retention_policy_days must be less than or equal to 365 when set."
  }
  validation {
    condition     = var.queue_properties == null || var.queue_properties.minute_metrics == null || var.queue_properties.minute_metrics.retention_policy_days == null || var.queue_properties.minute_metrics.retention_policy_days >= 1
    error_message = "queue_properties.minute_metrics.retention_policy_days must be greater than or equal to 1 when set."
  }
  validation {
    condition     = var.queue_properties == null || var.queue_properties.minute_metrics == null || var.queue_properties.minute_metrics.retention_policy_days == null || var.queue_properties.minute_metrics.retention_policy_days <= 365
    error_message = "queue_properties.minute_metrics.retention_policy_days must be less than or equal to 365 when set."
  }
}

variable "queue_encryption_key_type" {
  type        = string
  default     = null
  description = "(Optional) The encryption type of the queue service. Possible values are `Service` and `Account`. Defaults to `null` (Azure platform default of `Service`). Changing this forces a new resource to be created."
}

variable "queues" {
  type = map(object({
    metadata = optional(map(string))
    name     = string
    role_assignments = optional(map(object({
      role_definition_id_or_name             = string
      principal_id                           = string
      principal_type                         = optional(string, null)
      description                            = optional(string, null)
      skip_service_principal_aad_check       = optional(bool, false)
      condition                              = optional(string, null)
      condition_version                      = optional(string, null)
      delegated_managed_identity_resource_id = optional(string, null)
    })), {})
    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
      read   = optional(string)
      update = optional(string)
    }))
  }))
  default     = {}
  description = <<-EOT
A map of queues to create on the storage account. The map key is arbitrary; the value supports the following attributes. Defaults to `{}` (no queues).

- `name` - (Required) The name of the Queue which should be created within the Storage Account. Must be unique within the storage account. Changing this forces a new resource to be created.
- `metadata` - (Optional) A mapping of MetaData which should be assigned to this Storage Queue. Defaults to `null`.
- `role_assignments` - (Optional) A map of role assignments to create on the queue. Defaults to `{}`. See `var.role_assignments` for the attribute schema.
- `timeouts` - (Optional) Per-operation timeouts for the queue resource. Defaults to `null` (uses provider defaults inherited from `var.timeouts`). Supports:
  - `create` - (Optional) Timeout for create operations.
  - `delete` - (Optional) Timeout for delete operations.
  - `read` - (Optional) Timeout for read operations.
  - `update` - (Optional) Timeout for update operations.
EOT
  nullable    = false
}

variable "parent_id" {
  type        = string
  description = "(Required) The full resource ID of the parent resource that the diagnostic setting will be attached to (for example a Storage Account, blob service, queue service, table service, or file service)."
  nullable    = false
}

variable "diagnostic_settings" {
  type = map(object({
    name = optional(string, null)
    logs = optional(set(object({
      category       = optional(string, null)
      category_group = optional(string, null)
      enabled        = optional(bool, true)
      retention_policy = optional(object({
        days    = optional(number, 0)
        enabled = optional(bool, false)
      }), {})
    })), [])
    metrics = optional(set(object({
      category = optional(string, null)
      enabled  = optional(bool, true)
      retention_policy = optional(object({
        days    = optional(number, 0)
        enabled = optional(bool, false)
      }), {})
    })), [])
    log_analytics_destination_type           = optional(string, "Dedicated")
    workspace_resource_id                    = optional(string, null)
    storage_account_resource_id              = optional(string, null)
    event_hub_authorization_rule_resource_id = optional(string, null)
    event_hub_name                           = optional(string, null)
    marketplace_partner_resource_id          = optional(string, null)
  }))
  default     = {}
  description = <<-EOT
(Optional) A map of diagnostic settings to create against `parent_id`. Defaults to `{}` (no diagnostic settings). Uses the v2 diagnostic settings schema from `Azure/avm-utl-interfaces/azure`. The map key is arbitrary; the value supports the following attributes:

- `name` - (Optional) The name of the diagnostic setting. Defaults to `null` (auto-generated; not unique if you create multiple settings).
- `logs` - (Optional) A set of log entries to enable. Defaults to `[]`. Each entry supports:
  - `category` - (Optional) The name of an individual log category (e.g. `StorageWrite`). Defaults to `null`. Mutually exclusive with `category_group`.
  - `category_group` - (Optional) The name of a log category group (e.g. `allLogs`, `audit`). Defaults to `null`. Mutually exclusive with `category`.
  - `enabled` - (Optional) Whether the log entry is enabled. Defaults to `true`.
  - `retention_policy` - (Optional) Retention policy for the log entry. Defaults to `{}` (`days = 0`, `enabled = false`). Supports:
    - `days` - (Optional) The number of days for which to retain. Defaults to `0`.
    - `enabled` - (Optional) Whether the retention policy is enabled. Defaults to `false`.
- `metrics` - (Optional) A set of metric entries to enable. Defaults to `[]`. Each entry supports:
  - `category` - (Optional) The name of the metric category (e.g. `AllMetrics`, `Transaction`). Defaults to `null`.
  - `enabled` - (Optional) Whether the metric entry is enabled. Defaults to `true`.
  - `retention_policy` - (Optional) Retention policy for the metric entry. Defaults to `{}` (`days = 0`, `enabled = false`). Supports the same attributes as the `logs.retention_policy` block above.
- `log_analytics_destination_type` - (Optional) The destination type for the diagnostic setting. Possible values are `Dedicated` and `AzureDiagnostics`. Defaults to `Dedicated`.
- `workspace_resource_id` - (Optional) The resource ID of the log analytics workspace to send logs and metrics to. Defaults to `null`.
- `storage_account_resource_id` - (Optional) The resource ID of the storage account to send logs and metrics to. Defaults to `null`.
- `event_hub_authorization_rule_resource_id` - (Optional) The resource ID of the event hub authorization rule to send logs and metrics to. Defaults to `null`.
- `event_hub_name` - (Optional) The name of the event hub. Defaults to `null` (the default event hub will be selected).
- `marketplace_partner_resource_id` - (Optional) The full ARM resource ID of the Marketplace resource to which you would like to send Diagnostic Logs. Defaults to `null`.
EOT
  nullable    = false
}

variable "enable_telemetry" {
  type        = bool
  default     = true
  description = "(Optional) Controls telemetry for the underlying `Azure/avm-utl-interfaces/azure` module. Defaults to `true`."
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
(Optional) Retry configuration applied to each AzAPI diagnostic setting resource. Defaults to `null` (no custom retry).

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
(Optional) Per-operation timeouts applied to each AzAPI diagnostic setting resource. Defaults to `null` (provider defaults). Each value is a Go duration string (e.g. `30m`, `1h`).

- `create` - (Optional) Timeout for create operations. Defaults to `null`.
- `read` - (Optional) Timeout for read operations. Defaults to `null`.
- `update` - (Optional) Timeout for update operations. Defaults to `null`.
- `delete` - (Optional) Timeout for delete operations. Defaults to `null`.
EOT
}

variable "tracing_tags_header" {
  type        = string
  default     = null
  description = "(Optional) User-Agent string injected into AzAPI request headers for telemetry. Defaults to `null` (no custom header)."
}

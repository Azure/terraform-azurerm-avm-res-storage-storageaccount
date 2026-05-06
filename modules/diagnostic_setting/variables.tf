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
  description = "(Optional) A map of diagnostic settings to create against `parent_id`. Uses the v2 diagnostic settings schema from `Azure/avm-utl-interfaces/azure`."
  nullable    = false
}

variable "enable_telemetry" {
  type        = bool
  default     = true
  description = "Controls telemetry for the underlying `Azure/avm-utl-interfaces/azure` module."
  nullable    = false
}

variable "retry" {
  type = object({
    error_message_regex  = optional(list(string))
    interval_seconds     = optional(number)
    max_interval_seconds = optional(number)
  })
  default     = null
  description = "Retry configuration applied to each AzAPI diagnostic setting resource."
}

variable "timeouts" {
  type = object({
    create = optional(string)
    read   = optional(string)
    update = optional(string)
    delete = optional(string)
  })
  default     = null
  description = "Timeouts applied to each AzAPI diagnostic setting resource."
}

variable "tracing_tags_header" {
  type        = string
  default     = null
  description = "Optional User-Agent string injected into AzAPI request headers for telemetry."
}

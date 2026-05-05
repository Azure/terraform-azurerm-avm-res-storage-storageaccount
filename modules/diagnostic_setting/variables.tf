variable "target_resource_id" {
  type        = string
  description = "(Required) The full resource ID of the resource the diagnostic setting is being created on."
  nullable    = false
}

variable "name" {
  type        = string
  description = "(Required) The name of the diagnostic setting."
  nullable    = false
}

variable "log_categories" {
  type        = set(string)
  default     = []
  description = "(Optional) A set of individual log categories to enable."
  nullable    = false
}

variable "log_groups" {
  type        = set(string)
  default     = []
  description = "(Optional) A set of log category groups to enable (e.g. `allLogs`)."
  nullable    = false
}

variable "metric_categories" {
  type        = set(string)
  default     = ["AllMetrics"]
  description = "(Optional) A set of metric categories to enable."
  nullable    = false
}

variable "log_analytics_destination_type" {
  type        = string
  default     = "Dedicated"
  description = "(Optional) Destination type for log analytics. One of `Dedicated` or `AzureDiagnostics`."
}

variable "workspace_resource_id" {
  type        = string
  default     = null
  description = "(Optional) Resource ID of the Log Analytics workspace destination."
}

variable "storage_account_resource_id" {
  type        = string
  default     = null
  description = "(Optional) Resource ID of the storage account destination."
}

variable "event_hub_authorization_rule_resource_id" {
  type        = string
  default     = null
  description = "(Optional) Resource ID of the Event Hub authorization rule."
}

variable "event_hub_name" {
  type        = string
  default     = null
  description = "(Optional) The name of the Event Hub."
}

variable "marketplace_partner_resource_id" {
  type        = string
  default     = null
  description = "(Optional) The full ARM resource ID of the Marketplace Partner destination."
}

variable "retry" {
  type = object({
    error_message_regex  = optional(list(string))
    interval_seconds     = optional(number)
    max_interval_seconds = optional(number)
    multiplier           = optional(number)
    randomization_factor = optional(number)
  })
  default     = null
  description = "Retry configuration applied to the AzAPI resource."
}

variable "timeouts" {
  type = object({
    create = optional(string)
    read   = optional(string)
    update = optional(string)
    delete = optional(string)
  })
  default     = null
  description = "Timeouts applied to the AzAPI resource."
}

variable "tracing_tags_header" {
  type        = string
  default     = null
  description = "Optional User-Agent string injected into AzAPI request headers."
}

variable "name" {
  type        = string
  description = "(Required) The name of the table."
  nullable    = false
}

variable "storage_account_id" {
  type        = string
  description = "(Required) The full resource ID of the parent storage account."
  nullable    = false
}

variable "retry" {
  type = object({
    error_message_regex  = optional(list(string))
    interval_seconds     = optional(number)
    max_interval_seconds = optional(number)
  })
  default     = null
  description = "Retry configuration applied to AzAPI resources managed by this module."
}

variable "signed_identifiers" {
  type = list(object({
    id = string
    access_policy = optional(object({
      expiry_time = string
      permission  = string
      start_time  = string
    }))
  }))
  default     = null
  description = "(Optional) Signed identifiers / access policies for the table."
}

variable "timeouts" {
  type = object({
    create = optional(string)
    read   = optional(string)
    update = optional(string)
    delete = optional(string)
  })
  default     = null
  description = "Timeouts applied to AzAPI resources managed by this module."
}

variable "tracing_tags_header" {
  type        = string
  default     = null
  description = "Optional User-Agent string injected into AzAPI request headers."
}

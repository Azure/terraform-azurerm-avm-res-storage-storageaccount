variable "name" {
  type        = string
  description = "(Required) The name of the Data Lake Gen2 filesystem."
  nullable    = false
}

variable "storage_account_id" {
  type        = string
  description = "(Required) The full resource ID of the parent storage account."
  nullable    = false
}

variable "default_encryption_scope" {
  type        = string
  default     = null
  description = "(Optional) The default encryption scope to use for this filesystem."
}

variable "metadata" {
  type        = map(string)
  default     = null
  description = "(Optional) A mapping of key-value pairs assigned to this filesystem."
}

variable "retry" {
  type = object({
    error_message_regex  = optional(list(string))
    interval_seconds     = optional(number)
    max_interval_seconds = optional(number)
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

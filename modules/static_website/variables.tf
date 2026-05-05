variable "storage_account_id" {
  type        = string
  description = "(Required) The full resource ID of the parent storage account."
  nullable    = false
}

variable "error_404_document" {
  type        = string
  default     = null
  description = "(Optional) The absolute path to a custom webpage to use for 404 not-found errors."
}

variable "index_document" {
  type        = string
  default     = null
  description = "(Optional) The webpage that Azure Storage serves for requests to the root of a website or any subfolder."
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

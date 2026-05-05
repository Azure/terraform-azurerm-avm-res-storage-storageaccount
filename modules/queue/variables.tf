variable "storage_account_id" {
  type        = string
  description = "(Required) The full resource ID of the parent storage account."
  nullable    = false
}

variable "name" {
  type        = string
  description = "(Required) The name of the queue."
  nullable    = false
}

variable "metadata" {
  type        = map(string)
  default     = null
  description = "(Optional) A mapping of metadata to assign to this storage queue."
}

variable "role_assignments" {
  type = map(object({
    role_definition_id_or_name             = string
    principal_id                           = string
    principal_type                         = optional(string, null)
    description                            = optional(string, null)
    skip_service_principal_aad_check       = optional(bool, false)
    condition                              = optional(string, null)
    condition_version                      = optional(string, null)
    delegated_managed_identity_resource_id = optional(string, null)
  }))
  default     = {}
  description = "Map of role assignments to create at the queue scope."
  nullable    = false
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
  description = "Retry configuration applied to AzAPI resources managed by this module."
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

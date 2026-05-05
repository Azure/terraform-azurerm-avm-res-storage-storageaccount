variable "storage_account_id" {
  type        = string
  description = "(Required) The full resource ID of the parent storage account."
  nullable    = false
}

variable "name" {
  type        = string
  description = "(Required) The name of the file share."
  nullable    = false
}

variable "access_tier" {
  type        = string
  default     = null
  description = "(Optional) The access tier of the file share. Possible values are `Hot`, `Cool`, `TransactionOptimized`, `Premium`."
}

variable "enabled_protocol" {
  type        = string
  default     = null
  description = "(Optional) The protocol used for the share. Possible values are `SMB` and `NFS`."
}

variable "metadata" {
  type        = map(string)
  default     = null
  description = "(Optional) Metadata for the share."
}

variable "quota" {
  type        = number
  description = "(Required) The maximum size of the share, in gigabytes."
  nullable    = false
}

variable "root_squash" {
  type        = string
  default     = null
  description = "(Optional) The root squash behaviour for an NFS share. Possible values are `NoRootSquash`, `RootSquash`, `AllSquash`."
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
  description = "(Optional) Signed identifiers / access policies for the share."
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
  description = "Map of role assignments to create at the share scope."
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

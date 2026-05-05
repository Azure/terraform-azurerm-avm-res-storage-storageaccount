variable "name" {
  type        = string
  description = "(Required) The name of the local user."
  nullable    = false
}

variable "storage_account_id" {
  type        = string
  description = "(Required) The full resource ID of the parent storage account."
  nullable    = false
}

variable "home_directory" {
  type        = string
  default     = null
  description = "(Optional) The home directory of the storage account local user."
}

variable "permission_scope" {
  type = list(object({
    resource_name = string
    service       = string
    permissions = object({
      create = optional(bool)
      delete = optional(bool)
      list   = optional(bool)
      read   = optional(bool)
      write  = optional(bool)
    })
  }))
  default     = null
  description = "(Optional) A list of permission scopes for the local user."
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

variable "ssh_authorized_key" {
  type = list(object({
    description = optional(string)
    key         = string
  }))
  default     = null
  description = "(Optional) A list of SSH authorized keys for the local user."
}

variable "ssh_key_enabled" {
  type        = bool
  default     = false
  description = "(Optional) Whether SSH key authentication is enabled. Defaults to `false`."
}

variable "ssh_password_enabled" {
  type        = bool
  default     = false
  description = "(Optional) Whether SSH password authentication is enabled. Defaults to `false`."
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

variable "name" {
  type        = string
  description = "(Required) The name of the container."
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
  description = "(Optional) The default encryption scope to use for blob operations on the container."
}

variable "deny_encryption_scope_override" {
  type        = bool
  default     = null
  description = "(Optional) When set to true, blocks blob uploads from specifying a different encryption scope."
}

variable "enable_nfs_v3_all_squash" {
  type        = bool
  default     = null
  description = "(Optional) Enable NFSv3 all squash (only valid for NFSv3 enabled accounts)."
}

variable "enable_nfs_v3_root_squash" {
  type        = bool
  default     = null
  description = "(Optional) Enable NFSv3 root squash (only valid for NFSv3 enabled accounts)."
}

variable "immutable_storage_with_versioning" {
  type = object({
    enabled = bool
  })
  default     = null
  description = "(Optional) Configures container-level immutability with version-level WORM."
}

variable "metadata" {
  type        = map(string)
  default     = null
  description = "(Optional) Container metadata. Keys must be lowercase."
}

variable "public_access" {
  type        = string
  default     = "None"
  description = "(Optional) Specifies the level of public access. Valid values: `None`, `Blob`, `Container`. Defaults to `None`."
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

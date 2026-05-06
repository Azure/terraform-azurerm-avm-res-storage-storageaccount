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
  description = "(Optional) The default encryption scope to use for blob operations on the container. Defaults to `null` (the storage account default encryption scope is used)."
}

variable "deny_encryption_scope_override" {
  type        = bool
  default     = null
  description = "(Optional) When set to `true`, blocks blob uploads from specifying a different encryption scope. Defaults to `null` (`false`)."
}

variable "enable_nfs_v3_all_squash" {
  type        = bool
  default     = null
  description = "(Optional) Enable NFSv3 all squash (only valid for NFSv3 enabled accounts). Defaults to `null` (`false`)."
}

variable "enable_nfs_v3_root_squash" {
  type        = bool
  default     = null
  description = "(Optional) Enable NFSv3 root squash (only valid for NFSv3 enabled accounts). Defaults to `null` (`false`)."
}

variable "immutable_storage_with_versioning" {
  type = object({
    enabled = bool
  })
  default     = null
  description = <<-EOT
(Optional) Configures container-level immutability with version-level WORM. Defaults to `null` (immutability disabled).

- `enabled` - (Required) Whether immutable storage with versioning is enabled.
EOT
}

variable "metadata" {
  type        = map(string)
  default     = null
  description = "(Optional) Container metadata. Keys must be lowercase. Defaults to `null` (no metadata)."
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
  description = <<-EOT
(Optional) Retry configuration applied to AzAPI resources managed by this module. Defaults to `null` (no custom retry).

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
(Optional) Per-operation timeouts applied to AzAPI resources managed by this module. Defaults to `null` (provider defaults). Each value is a Go duration string (e.g. `30m`, `1h`).

- `create` - (Optional) Timeout for create operations. Defaults to `null`.
- `read` - (Optional) Timeout for read operations. Defaults to `null`.
- `update` - (Optional) Timeout for update operations. Defaults to `null`.
- `delete` - (Optional) Timeout for delete operations. Defaults to `null`.
EOT
}

variable "tracing_tags_header" {
  type        = string
  default     = null
  description = "(Optional) User-Agent string injected into AzAPI request headers. Defaults to `null` (no custom header)."
}

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
  description = "(Optional) The home directory of the storage account local user. Defaults to `null`."
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
  description = <<-EOT
(Optional) A list of permission scopes for the local user. Defaults to `null` (no scopes). Each entry supports:

- `resource_name` - (Required) The container name (when `service` is set to `blob`) or the file share name (when `service` is set to `file`).
- `service` - (Required) The storage service used by this Storage Account Local User. Possible values are `blob` and `file`.
- `permissions` - (Required) An object describing the permissions granted at this scope. Supports:
  - `create` - (Optional) Whether the local user has the create permission for this scope. Defaults to `null` (`false`).
  - `delete` - (Optional) Whether the local user has the delete permission for this scope. Defaults to `null` (`false`).
  - `list` - (Optional) Whether the local user has the list permission for this scope. Defaults to `null` (`false`).
  - `read` - (Optional) Whether the local user has the read permission for this scope. Defaults to `null` (`false`).
  - `write` - (Optional) Whether the local user has the write permission for this scope. Defaults to `null` (`false`).
EOT
}

variable "retry" {
  type = object({
    error_message_regex  = optional(list(string))
    interval_seconds     = optional(number)
    max_interval_seconds = optional(number)
  })
  default     = null
  description = <<-EOT
(Optional) Retry configuration applied to the AzAPI resource. Defaults to `null` (no custom retry).

- `error_message_regex` - (Optional) A list of regex patterns matching error messages that trigger a retry. Defaults to `null`.
- `interval_seconds` - (Optional) Initial interval between retries in seconds. Defaults to `null` (provider default).
- `max_interval_seconds` - (Optional) Maximum interval between retries in seconds. Defaults to `null` (provider default).
EOT
}

variable "ssh_authorized_key" {
  type = list(object({
    description = optional(string)
    key         = string
  }))
  default     = null
  description = <<-EOT
(Optional) A list of SSH authorized keys for the local user. Defaults to `null` (no keys). Each entry supports:

- `key` - (Required) The public key value of this SSH authorized key.
- `description` - (Optional) The description of this SSH authorized key. Defaults to `null`.
EOT
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
  description = <<-EOT
(Optional) Per-operation timeouts applied to the AzAPI resource. Defaults to `null` (provider defaults). Each value is a Go duration string (e.g. `30m`, `1h`).

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

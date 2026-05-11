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
  description = <<-EOT
(Optional) Retry configuration applied to AzAPI resources managed by this module. Defaults to `null` (no custom retry).

- `error_message_regex` - (Optional) A list of regex patterns matching error messages that trigger a retry. Defaults to `null`.
- `interval_seconds` - (Optional) Initial interval between retries in seconds. Defaults to `null` (provider default).
- `max_interval_seconds` - (Optional) Maximum interval between retries in seconds. Defaults to `null` (provider default).
EOT
}

variable "role_assignment_definition_lookup_enabled" {
  type        = bool
  default     = true
  description = "(Optional) Whether the `role_assignments` submodule should resolve role definition names supplied via `role_definition_id_or_name` by querying the Azure Authorization API. Defaults to `true`. See the `role_assignments` submodule for details."
  nullable    = false
}

variable "role_assignments" {
  type = map(object({
    role_definition_id_or_name             = string
    principal_id                           = string
    description                            = optional(string, null)
    skip_service_principal_aad_check       = optional(bool, false)
    condition                              = optional(string, null)
    condition_version                      = optional(string, null)
    delegated_managed_identity_resource_id = optional(string, null)
    principal_type                         = optional(string, null)
  }))
  default     = {}
  description = "(Optional) A map of role assignments to create at the table scope. Defaults to `{}`. See the `role_assignments` submodule for the attribute schema."
  nullable    = false
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
  description = <<-EOT
(Optional) Signed identifiers / stored access policies for the table. Defaults to `null` (no signed identifiers). A maximum of 5 signed identifiers may be defined. Each entry supports:

- `id` - (Required) The ID for this signed identifier (1-64 characters).
- `access_policy` - (Optional) The access policy for this signed identifier. Defaults to `null`. Supports:
  - `expiry_time` - (Required) The ISO-8601 UTC time at which the access policy expires.
  - `permission` - (Required) The permissions granted by the access policy. Possible values include any combination of `r` (read), `a` (add), `u` (update), and `d` (delete).
  - `start_time` - (Required) The ISO-8601 UTC time at which the access policy becomes valid.
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

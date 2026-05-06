variable "scope" {
  type        = string
  description = "(Required) The fully-qualified Azure resource ID at which the role assignments should be created (the parent_id for the roleAssignment resource)."
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
(Optional) Retry configuration applied to every AzAPI resource managed by this module. Defaults to `null` (no custom retry). See AzAPI provider docs for details.

- `error_message_regex` - (Optional) A list of regex patterns matching error messages that trigger a retry. Defaults to `null`.
- `interval_seconds` - (Optional) Initial interval between retries in seconds. Defaults to `null` (provider default).
- `max_interval_seconds` - (Optional) Maximum interval between retries in seconds. Defaults to `null` (provider default).
EOT
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
  description = <<-EOT
(Optional) A map of role assignments to create at the supplied scope. Defaults to `{}` (no role assignments). The map key is deliberate so that consumers can manage these resources predictably. Each value supports:

- `role_definition_id_or_name` - (Required) Either the full resource ID of the role definition (`/subscriptions/<sub>/providers/Microsoft.Authorization/roleDefinitions/<id>`) or the role name (e.g. `Storage Blob Data Owner`).
- `principal_id` - (Required) The principal id to assign the role to.
- `description` - (Optional) Description of the role assignment. Defaults to `null`.
- `skip_service_principal_aad_check` - (Optional) Retained for backwards compatibility. Not honoured by AzAPI; left here so the variable shape matches the upstream module. Defaults to `false`.
- `condition` - (Optional) Conditional access expression. Defaults to `null`.
- `condition_version` - (Optional) Conditional access expression version. Required when `condition` is supplied. Defaults to `null`.
- `delegated_managed_identity_resource_id` - (Optional) The resource ID of the delegated managed identity. Defaults to `null`.
- `principal_type` - (Optional) The type of principal. Possible values are `User`, `Group`, `ServicePrincipal`, `ForeignGroup`, and `Device`. Defaults to `null`.
EOT
  nullable    = false
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
(Optional) Per-operation timeouts applied to every AzAPI resource managed by this module. Defaults to `null` (provider defaults). Each value is a Go duration string (e.g. `30m`, `1h`).

- `create` - (Optional) Timeout for create operations. Defaults to `null`.
- `read` - (Optional) Timeout for read operations. Defaults to `null`.
- `update` - (Optional) Timeout for update operations. Defaults to `null`.
- `delete` - (Optional) Timeout for delete operations. Defaults to `null`.
EOT
}

variable "tracing_tags_header" {
  type        = string
  default     = null
  description = "(Optional) User-Agent string injected as the `User-Agent` request header for all AzAPI requests. Pass `local.avm_azapi_header` from the calling module. Defaults to `null` (no custom header)."
}

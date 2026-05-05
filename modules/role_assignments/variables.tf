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
  description = "Retry configuration applied to every AzAPI resource managed by this module. See AzAPI provider docs for details."
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
A map of role assignments to create at the supplied scope. The map key is deliberate so that consumers can manage these resources predictably.

- `role_definition_id_or_name`           - (Required) Either the full resource ID of the role definition (`/subscriptions/<sub>/providers/Microsoft.Authorization/roleDefinitions/<id>`) or the role name (e.g. `Storage Blob Data Owner`).
- `principal_id`                         - (Required) The principal id to assign the role to.
- `description`                          - (Optional) Description of the role assignment.
- `skip_service_principal_aad_check`     - (Optional) Retained for backwards compatibility. Not honoured by AzAPI; left here so the variable shape matches the upstream module.
- `condition`                            - (Optional) Conditional access expression.
- `condition_version`                    - (Optional) Conditional access expression version. Required when `condition` is supplied.
- `delegated_managed_identity_resource_id` - (Optional) The resource ID of the delegated managed identity.
- `principal_type`                       - (Optional) The type of principal (`User`, `Group`, `ServicePrincipal`, `ForeignGroup`, `Device`).
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
  description = "Timeouts applied to every AzAPI resource managed by this module."
}

variable "tracing_tags_header" {
  type        = string
  default     = null
  description = "Optional User-Agent string injected as `User-Agent` request header for all AzAPI requests. Pass `local.avm_azapi_header` from the calling module."
}

variable "table_encryption_key_type" {
  type        = string
  default     = null
  description = "(Optional) The encryption type of the table service. Possible values are `Service` and `Account`. Defaults to `null` (Azure platform default of `Service`). Changing this forces a new resource to be created."
}

variable "tables" {
  type = map(object({
    name = string
    signed_identifiers = optional(list(object({
      id = string
      access_policy = optional(object({
        expiry_time = string
        permission  = string
        start_time  = string
      }))
    })))

    role_assignments = optional(map(object({
      role_definition_id_or_name             = string
      principal_id                           = string
      principal_type                         = optional(string, null)
      description                            = optional(string, null)
      skip_service_principal_aad_check       = optional(bool, false)
      condition                              = optional(string, null)
      condition_version                      = optional(string, null)
      delegated_managed_identity_resource_id = optional(string, null)
    })), {})

    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
      read   = optional(string)
      update = optional(string)
    }))
  }))
  default     = {}
  description = <<-EOT
A map of tables to create on the storage account. The map key is arbitrary; the value supports the following attributes. Defaults to `{}` (no tables).

- `name` - (Required) The name of the storage table. Only alphanumeric characters allowed, starting with a letter. Must be unique within the storage account. Changing this forces a new resource to be created.
- `signed_identifiers` - (Optional) A list of signed identifiers (stored access policies) to apply to the table. Defaults to `null`. Each entry supports:
  - `id` - (Required) The ID for this signed identifier. Maximum 64 characters.
  - `access_policy` - (Optional) The access policy for this identifier. Defaults to `null`. Supports:
    - `expiry_time` - (Required) The ISO8601 UTC time at which this access policy should expire.
    - `permission` - (Required) The permissions associated with this signed identifier. A combination of `r` (read), `a` (add), `u` (update), and `d` (delete).
    - `start_time` - (Required) The ISO8601 UTC time at which this access policy becomes valid.
- `role_assignments` - (Optional) A map of role assignments to create on the table. Defaults to `{}`. See `var.role_assignments` for the attribute schema.
- `timeouts` - (Optional) Per-operation timeouts for the table resource. Defaults to `null` (uses provider defaults inherited from `var.timeouts`). Supports:
  - `create` - (Optional) Timeout for create operations.
  - `delete` - (Optional) Timeout for delete operations.
  - `read` - (Optional) Timeout for read operations.
  - `update` - (Optional) Timeout for update operations.
EOT
  nullable    = false
}

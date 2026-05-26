variable "containers" {
  type = map(object({
    public_access                  = optional(string, "None")
    metadata                       = optional(map(string))
    name                           = string
    default_encryption_scope       = optional(string)
    deny_encryption_scope_override = optional(bool)
    enable_nfs_v3_all_squash       = optional(bool)
    enable_nfs_v3_root_squash      = optional(bool)
    immutable_storage_with_versioning = optional(object({
      enabled = bool
    }))

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
A map of containers to create on the storage account. The map key is arbitrary; the value supports the following attributes. Defaults to `{}` (no containers).

- `name` - (Required) The name of the Container which should be created within the Storage Account. Changing this forces a new resource to be created.
- `public_access` - (Optional) Specifies whether data in the container may be accessed publicly and the level of access. Possible values are `Container`, `Blob`, and `None`. Defaults to `None`. Changing this forces a new resource to be created.
- `metadata` - (Optional) A mapping of MetaData for this Container. All metadata keys should be lowercase. Defaults to `null`.
- `default_encryption_scope` - (Optional) The default encryption scope to use for blob operations on this container. Defaults to `null`.
- `deny_encryption_scope_override` - (Optional) When set to `true`, blocks blob uploads from specifying a different encryption scope. Defaults to `null`.
- `enable_nfs_v3_all_squash` - (Optional) Enable NFSv3 all squash (only valid for NFSv3 enabled accounts). Defaults to `null`.
- `enable_nfs_v3_root_squash` - (Optional) Enable NFSv3 root squash (only valid for NFSv3 enabled accounts). Defaults to `null`.
- `immutable_storage_with_versioning` - (Optional) Configures container-level immutability with version-level WORM. Defaults to `null`. Supports:
  - `enabled` - (Required) Whether immutable storage with versioning is enabled.
- `role_assignments` - (Optional) A map of role assignments to create on the container. Defaults to `{}`. See `var.role_assignments` for the attribute schema.
- `timeouts` - (Optional) Per-operation timeouts for the container resource. Defaults to `null` (uses provider defaults inherited from `var.timeouts`). Supports:
  - `create` - (Optional) Timeout for create operations.
  - `delete` - (Optional) Timeout for delete operations.
  - `read` - (Optional) Timeout for read operations.
  - `update` - (Optional) Timeout for update operations.
EOT
  nullable    = false
}

variable "immutability_policy" {
  type = object({
    allow_protected_append_writes = bool
    period_since_creation_in_days = number
    state                         = string
  })
  default     = null
  description = <<-EOT
Configures the account-level immutability policy. Defaults to `null` (no policy).

- `allow_protected_append_writes` - (Required) When enabled, new blocks can be written to an append blob while maintaining immutability protection and compliance. Only new blocks can be added; any existing blocks cannot be modified or deleted.
- `period_since_creation_in_days` - (Required) The immutability period for the blobs in the container since the policy creation, in days.
- `state` - (Required) The mode of the policy. `Disabled` disables the policy; `Unlocked` allows the immutability retention time to be increased or decreased and toggling `allow_protected_append_writes`; `Locked` only allows the immutability retention time to be increased. A policy may only be created in `Disabled` or `Unlocked`, may be toggled between those two, and `Unlocked` may transition to `Locked` (which cannot be reverted).
EOT
}

variable "is_hns_enabled" {
  type        = bool
  default     = null
  description = "(Optional) Is Hierarchical Namespace enabled? This can be used with Azure Data Lake Storage Gen 2 ([see here for more information](https://docs.microsoft.com/azure/storage/blobs/data-lake-storage-quickstart-create-account/)). Defaults to `null` (Azure platform default of `false`). Changing this forces a new resource to be created."
}

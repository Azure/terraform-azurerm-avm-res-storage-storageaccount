# NOTE: var.blob_properties (blob service-level versioning, change feed,
# CORS, retention policies) was removed in v1.0.0 (azapi rewrite). Configure
# those settings directly via
# Microsoft.Storage/storageAccounts/blobServices@2024-01-01 if needed; this
# module no longer exposes them.

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
 - `public_access` - (Optional) Specifies whether data in the container may be accessed publicly and the level of access. Possible values are `Container`, `Blob`, and `None`. Defaults to `None`. Changing this forces a new resource to be created.
 - `metadata` - (Optional) A mapping of MetaData for this Container. All metadata keys should be lowercase.
 - `name` - (Required) The name of the Container which should be created within the Storage Account. Changing this forces a new resource to be created.

 Supply role assignments in the same way as for `var.role_assignments`.

 ---
 `timeouts` block supports the following:
 - `create` - (Defaults to 30 minutes) Used when creating the Storage Container.
 - `delete` - (Defaults to 30 minutes) Used when deleting the Storage Container.
 - `read` - (Defaults to 5 minutes) Used when retrieving the Storage Container.
 - `update` - (Defaults to 30 minutes) Used when updating the Storage Container.
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
 - `allow_protected_append_writes` - (Required) When enabled, new blocks can be written to an append blob while maintaining immutability protection and compliance. Only new blocks can be added and any existing blocks cannot be modified or deleted.
 - `period_since_creation_in_days` - (Required) The immutability period for the blobs in the container since the policy creation, in days.
 - `state` - (Required) Defines the mode of the policy. `Disabled` state disables the policy, `Unlocked` state allows increase and decrease of immutability retention time and also allows toggling allowProtectedAppendWrites property, `Locked` state only allows the increase of the immutability retention time. A policy can only be created in a Disabled or Unlocked state and can be toggled between the two states. Only a policy in an Unlocked state can transition to a Locked state which cannot be reverted.
EOT
}

variable "is_hns_enabled" {
  type        = bool
  default     = null
  description = "(Optional) Is Hierarchical Namespace enabled? This can be used with Azure Data Lake Storage Gen 2 ([see here for more information](https://docs.microsoft.com/azure/storage/blobs/data-lake-storage-quickstart-create-account/)). Changing this forces a new resource to be created."
}

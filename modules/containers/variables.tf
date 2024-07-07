variable "storage_account" {
  type = object({
    resource_id = string
  })
}
variable "name" {
  type = string

}
variable "metadata" {
  type        = map(string)
  description = <<DESCRIPTION
  (Optional) A mapping of metadata to associate with the queue.
  DESCRIPTION
  nullable    = true
  default     = {}
}

variable "public_access" {
  type     = string
  default  = "none"
  nullable = true

}

variable "immutable_storage_with_versioning" {
  type = object({
    enabled = bool
  })
  default     = null
  description = <<DESCRIPTION
  (Optional) An object representing the immutable storage with versioning configuration for the container.
  DESCRIPTION
  nullable    = true

}


variable "containers" {
  type = map(object({
    public_access                  = optional(string, "None") //TODO: validate
    default_encryption_scope       = optional(string)
    deny_encryption_scope_override = optional(bool)
    enable_nfs_v3_all_squash       = optional(bool)
    enable_nfs_v3_root_squash      = optional(bool)
    immutable_storage_with_versioning = optional(object({ //TODO: validate
      enabled = bool
    }))
    //TODO: remove and dedicated block (role_assignments)
    role_assignments = optional(map(object({
      role_definition_id_or_name             = string
      principal_id                           = string
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
 - `container_access_type` - (Optional) The Access Level configured for this Container. Possible values are `Blob`, `Container` or `None`. Defaults to `None`.
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

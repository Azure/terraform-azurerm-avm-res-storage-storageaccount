variable "storage_data_lake_gen2_filesystems" {
  type = map(object({
    default_encryption_scope = optional(string)
    group                    = optional(string)
    name                     = string
    owner                    = optional(string)
    properties               = optional(map(string))
    ace = optional(set(object({
      id          = optional(string)
      permissions = string
      scope       = optional(string)
      type        = string
    })))
    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
      read   = optional(string)
      update = optional(string)
    }))
  }))
  default     = {}
  description = <<-EOT
 - `default_encryption_scope` - (Optional) The default encryption scope to use for this filesystem. Changing this forces a new resource to be created.
 - `group` - (Optional) Specifies the Object ID of the Azure Active Directory Group to make the owning group of the root path (i.e. `/`). Possible values also include `$superuser`.
 - `name` - (Required) The name of the Data Lake Gen2 File System which should be created within the Storage Account. Must be unique within the storage account the queue is located. Changing this forces a new resource to be created.
 - `owner` - (Optional) Specifies the Object ID of the Azure Active Directory User to make the owning user of the root path (i.e. `/`). Possible values also include `$superuser`.
 - `properties` - (Optional) A mapping of Key to Base64-Encoded Values which should be assigned to this Data Lake Gen2 File System.
 ---
 `ace` block supports the following:
 - `id` - (Optional) Specifies the Object ID of the Azure Active Directory User or Group that the entry relates to. Only valid for `user` or `group` entries.
 - `permissions` - (Required) Specifies the permissions for the entry in `rwx` form. For example, `rwx` gives full permissions but `r--` only gives read permissions.
 - `scope` - (Optional) Specifies whether the ACE represents an `access` entry or a `default` entry. Default value is `access`.
 - `type` - (Required) Specifies the type of entry. Can be `user`, `group`, `mask` or `other`.

 ---
 `timeouts` block supports the following:
 - `create` - (Defaults to 30 minutes) Used when creating the Data Lake Gen2 File System.
 - `delete` - (Defaults to 30 minutes) Used when deleting the Data Lake Gen2 File System.
 - `read` - (Defaults to 5 minutes) Used when retrieving the Data Lake Gen2 File System.
 - `update` - (Defaults to 30 minutes) Used when updating the Data Lake Gen2 File System.
EOT

  validation {
    condition     = !contains(keys(var.storage_data_lake_gen2_filesystems), "legacy")
    error_message = "Key `legacy` is preserved for backward compatibility."
  }
}

variable "storage_data_lake_gen2_paths" {
  type = map(object({
    path            = string
    filesystem_name = string
    resource        = string
    owner           = optional(string)
    group           = optional(string)
    ace = optional(set(object({
      id          = optional(string)
      permissions = string
      scope       = optional(string)
      type        = string
    })))
    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
      read   = optional(string)
      update = optional(string)
    }))
  }))
  default     = {}
  description = <<-EOT
 - `path` - (Required) The path which should be created within the Data Lake Gen2 File System in the Storage Account. Changing this forces a new resource to be created.
 - `filesystem_name` - (Required) The name of the Data Lake Gen2 File System which should be created within the Storage Account. Changing this forces a new resource to be created.
 - `storage_account_id` - (Required) The ID of the Storage Account where the Data Lake Gen2 File System exists. Changing this forces a new resource to be created.
 - `resource` - (Required) The type of resource. Possible values are `directory` or `file`. Changing this forces a new resource to be created.
 - `owner` - (Optional) Specifies the Object ID of the Azure Active Directory User to make the owning user. Possible values also include `$superuser`.
 - `group` - (Optional) Specifies the Object ID of the Azure Active Directory Group to make the owning group. Possible values also include `$superuser`.

 ---
 `ace` block supports the following:
 - `id` - (Optional) Specifies the Object ID of the Azure Active Directory User or Group that the entry relates to. Only valid for `user` or `group` entries.
 - `permissions` - (Required) Specifies the permissions for the entry in `rwx` form. For example, `rwx` gives full permissions but `r--` only gives read permissions.
 - `scope` - (Optional) Specifies whether the ACE represents an `access` entry or a `default` entry. Default value is `access`.
 - `type` - (Required) Specifies the type of entry. Can be `user`, `group`, `mask` or `other`.

 ---
 `timeouts` block supports the following:
 - `create` - (Defaults to 30 minutes) Used when creating the Data Lake Gen2 Path.
 - `delete` - (Defaults to 30 minutes) Used when deleting the Data Lake Gen2 Path.
 - `read` - (Defaults to 5 minutes) Used when retrieving the Data Lake Gen2 Path.
 - `update` - (Defaults to 30 minutes) Used when updating the Data Lake Gen2 Path.
EOT
  nullable    = false
}

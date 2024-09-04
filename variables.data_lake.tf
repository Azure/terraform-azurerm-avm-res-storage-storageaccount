variable "storage_data_lake_gen2_filesystem_name" {
  type        = string
  description = "(Required) The name of the Data Lake Gen2 File System which should be created within the Storage Account. Must be unique within the storage account the queue is located. Changing this forces a new resource to be created."
  nullable    = false
}

variable "storage_data_lake_gen2_filesystem_storage_account_id" {
  type        = string
  description = "(Required) Specifies the ID of the Storage Account in which the Data Lake Gen2 File System should exist. Changing this forces a new resource to be created."
  nullable    = false
}

variable "storage_data_lake_gen2_filesystem_ace" {
  type = set(object({
    id          = optional(string)
    permissions = string
    scope       = optional(string)
    type        = string
  }))
  default     = null
  description = <<-EOT
 - `id` - (Optional) Specifies the Object ID of the Azure Active Directory User or Group that the entry relates to. Only valid for `user` or `group` entries.
 - `permissions` - (Required) Specifies the permissions for the entry in `rwx` form. For example, `rwx` gives full permissions but `r--` only gives read permissions.
 - `scope` - (Optional) Specifies whether the ACE represents an `access` entry or a `default` entry. Default value is `access`.
 - `type` - (Required) Specifies the type of entry. Can be `user`, `group`, `mask` or `other`.
EOT
}

variable "storage_data_lake_gen2_filesystem_default_encryption_scope" {
  type        = string
  default     = null
  description = "(Optional) The default encryption scope to use for this filesystem. Changing this forces a new resource to be created."
}

variable "storage_data_lake_gen2_filesystem_group" {
  type        = string
  default     = null
  description = "(Optional) Specifies the Object ID of the Azure Active Directory Group to make the owning group of the root path (i.e. `/`). Possible values also include `$superuser`."
}

variable "storage_data_lake_gen2_filesystem_owner" {
  type        = string
  default     = null
  description = "(Optional) Specifies the Object ID of the Azure Active Directory User to make the owning user of the root path (i.e. `/`). Possible values also include `$superuser`."
}

variable "storage_data_lake_gen2_filesystem_properties" {
  type        = map(string)
  default     = null
  description = "(Optional) A mapping of Key to Base64-Encoded Values which should be assigned to this Data Lake Gen2 File System."
}

variable "storage_data_lake_gen2_filesystem_timeouts" {
  type = object({
    create = optional(string)
    delete = optional(string)
    read   = optional(string)
    update = optional(string)
  })
  default     = null
  description = <<-EOT
 - `create` - (Defaults to 30 minutes) Used when creating the Data Lake Gen2 File System.
 - `delete` - (Defaults to 30 minutes) Used when deleting the Data Lake Gen2 File System.
 - `read` - (Defaults to 5 minutes) Used when retrieving the Data Lake Gen2 File System.
 - `update` - (Defaults to 30 minutes) Used when updating the Data Lake Gen2 File System.
EOT
}

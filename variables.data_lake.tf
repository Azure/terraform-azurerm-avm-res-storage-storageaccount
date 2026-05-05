variable "storage_data_lake_gen2_filesystems" {
  type = map(object({
    default_encryption_scope = optional(string)
    name                     = string
    properties               = optional(map(string))
    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
      read   = optional(string)
      update = optional(string)
    }))
  }))
  default     = {}
  description = <<-EOT
A map of Data Lake Gen2 filesystems to create on the storage account.

- `default_encryption_scope` - (Optional) The default encryption scope to use for this filesystem. Changing this forces a new resource to be created.
- `name` - (Required) The name of the Data Lake Gen2 File System which should be created within the Storage Account. Must be unique within the storage account. Changing this forces a new resource to be created.
- `properties` - (Optional) A mapping of key/value pairs assigned to this filesystem (passed as ARM container metadata).

> **v1.0.0 BREAKING CHANGE**: The `owner`, `group` and `ace` (POSIX ACL) fields, plus the standalone `var.storage_data_lake_gen2_paths` variable, are no longer supported. Those features required Data Lake DFS data-plane API calls which the AzAPI provider does not exercise. Manage them externally if required (see `examples/data_lake_gen2/` for a recipe using `azurerm_storage_data_lake_gen2_path` alongside this module).

---
`timeouts` block supports the following:
- `create` - Used when creating the Data Lake Gen2 File System.
- `delete` - Used when deleting the Data Lake Gen2 File System.
- `read` - Used when retrieving the Data Lake Gen2 File System.
- `update` - Used when updating the Data Lake Gen2 File System.
EOT

  validation {
    condition     = !contains(keys(var.storage_data_lake_gen2_filesystems), "legacy")
    error_message = "Key `legacy` is reserved for state-migration backwards compatibility."
  }
}

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
A map of Data Lake Gen2 filesystems to create on the storage account. The map key is arbitrary; the value supports the following attributes. Defaults to `{}` (no filesystems).

- `name` - (Required) The name of the Data Lake Gen2 File System which should be created within the Storage Account. Must be unique within the storage account. Changing this forces a new resource to be created.
- `default_encryption_scope` - (Optional) The default encryption scope to use for this filesystem. Defaults to `null`. Changing this forces a new resource to be created.
- `properties` - (Optional) A mapping of key/value pairs assigned to this filesystem (passed as ARM container metadata). Defaults to `null`.
- `timeouts` - (Optional) Per-operation timeouts for the filesystem resource. Defaults to `null` (uses provider defaults inherited from `var.timeouts`). Supports:
  - `create` - (Optional) Timeout for create operations.
  - `delete` - (Optional) Timeout for delete operations.
  - `read` - (Optional) Timeout for read operations.
  - `update` - (Optional) Timeout for update operations.

> **v1.0.0 BREAKING CHANGE**: The `owner`, `group` and `ace` (POSIX ACL) fields, plus the standalone `var.storage_data_lake_gen2_paths` variable, are no longer supported. Those features required Data Lake DFS data-plane API calls which the AzAPI provider does not exercise. Manage them externally if required (see `examples/data_lake_gen2/` for a recipe using `azurerm_storage_data_lake_gen2_path` alongside this module).
EOT

  validation {
    condition     = !contains(keys(var.storage_data_lake_gen2_filesystems), "legacy")
    error_message = "Key `legacy` is reserved for state-migration backwards compatibility."
  }
}

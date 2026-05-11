# Data Lake Gen2 example

Deploys a Storage Account with hierarchical namespace enabled and two Data
Lake Gen2 filesystems managed via this module's `storage_data_lake_gen2_filesystems`
variable.

> [!IMPORTANT]
> v1.0.0 BREAKING CHANGE: this module no longer manages the Data Lake Gen2
> data plane (POSIX ACLs, owner/group, paths). The companion
> `azurerm_storage_data_lake_gen2_path` resources at the bottom of
> `main.tf` show the recommended pattern for managing those features
> alongside the module by declaring them directly with the `azurerm`
> provider against `module.this.resource_id`. AzAPI does not currently
> expose the DFS data-plane API needed for these operations.

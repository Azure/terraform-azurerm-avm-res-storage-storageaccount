<!-- BEGIN_TF_DOCS -->
# Submodule: blob_service

This submodule is independently consumable and can be called directly. It is also used by `terraform-azurerm-avm-res-storage-storageaccount`.

**ARM Resource Type**: `Microsoft.Storage/storageAccounts/blobServices@2025-06-01`

## Features

- Blob versioning
- Change feed (with optional retention period)
- Blob soft-delete (with optional permanent-delete allowance)
- Container soft-delete (with optional permanent-delete allowance)
- Point-in-time restore
- Last access time tracking
- CORS rules
- Default service version

## Usage

This submodule can be consumed directly, or via the root module's `blob_properties` variable:

```terraform
module "storage_account" {
  source = "Azure/avm-res-storage-storageaccount/azurerm"

  # ... other configuration ...

  blob_properties = {
    versioning_enabled = true
    change_feed = {
      enabled           = true
      retention_in_days = 14
    }
    delete_retention_policy = {
      enabled = true
      days    = 14
    }
    container_delete_retention_policy = {
      enabled = true
      days    = 14
    }
    restore_policy = {
      enabled = true
      days    = 7
    }
  }
}
```


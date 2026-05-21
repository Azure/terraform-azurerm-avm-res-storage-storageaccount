<!-- BEGIN_TF_DOCS -->
# Internal submodule: blob_service

This is an internal submodule used by `terraform-azurerm-avm-res-storage-storageaccount`. Consumers MUST NOT call this submodule directly. Refer to the root module for supported inputs.

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

Configure blob service properties via the root module's `blob_properties` variable:

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


<!-- BEGIN_TF_DOCS -->
# Queue Service Submodule

This submodule configures queue service properties for an Azure Storage Account.

**ARM Resource Type**: `Microsoft.Storage/storageAccounts/queueServices@2025-06-01`

## Features

- CORS rules configuration
- ARM-safe queue service patching

## Usage

This submodule can be consumed directly, or via the root module's `queue_properties` variable.

```hcl
module "storage_account" {
  source = "Azure/avm-res-storage-storageaccount/azurerm"

  # ... other configuration ...

  queue_properties = {
    cors_rules = [
      {
        allowed_origins    = ["https://example.com"]
        allowed_methods    = ["GET", "POST"]
        allowed_headers    = ["*"]
        exposed_headers    = ["*"]
        max_age_in_seconds = 3600
      }
    ]
  }
}
```

Queue Storage analytics logging and metrics are not included here because the ARM `queueServices/default` patch path does not persist those settings reliably.

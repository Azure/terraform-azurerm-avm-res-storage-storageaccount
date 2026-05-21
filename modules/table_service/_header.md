# Table Service Submodule

This submodule configures table service properties for an Azure Storage Account.

**ARM Resource Type**: `Microsoft.Storage/storageAccounts/tableServices@2025-06-01`

## Features

- CORS rules configuration
- ARM-safe table service patching

## Usage

This submodule is used via the root module's `table_properties` variable. It is not intended to be called directly.

```hcl
module "storage_account" {
  source = "Azure/avm-res-storage-storageaccount/azurerm"

  # ... other configuration ...

  table_properties = {
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

Table Storage analytics logging and metrics are not included here because the ARM `tableServices/default` patch path does not persist those settings reliably.

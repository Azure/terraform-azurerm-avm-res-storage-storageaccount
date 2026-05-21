# Table Service Submodule

This submodule configures table service properties for an Azure Storage Account.

**ARM Resource Type**: `Microsoft.Storage/storageAccounts/tableServices@2025-06-01`

## Features

- CORS rules configuration
- Storage Analytics logging (read, write, delete operations)
- Hourly metrics collection
- Minute-level metrics collection

## Usage

This submodule is used via the root module's `table_properties` variable. It is not intended to be called directly.

```hcl
module "storage_account" {
  source = "Azure/avm-res-storage-storageaccount/azurerm"

  # ... other configuration ...

  table_properties = {
    logging = {
      delete                = true
      read                  = true
      write                 = true
      retention_policy_days = 7
    }
    hour_metrics = {
      enabled               = true
      include_apis          = true
      retention_policy_days = 7
    }
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

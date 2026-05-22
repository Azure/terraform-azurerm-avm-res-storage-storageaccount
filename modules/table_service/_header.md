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

## Idempotency note

The ARM `GET` on `tableServices/default` does not echo back the `corsRules`
that were just `PATCH`ed, even though the `PATCH` itself succeeds and the
rules are applied. To avoid perpetual plan drift, this submodule applies
`lifecycle.ignore_changes = [body.properties.cors]`. As a result, CORS rules
are applied when the resource is first created, but later changes to
`cors_rules` will not be detected by `terraform plan`. To update the CORS
rules, taint or replace the underlying resource, for example:

```bash
terraform taint 'module.<storage_account>.module.table_service[0].azapi_update_resource.this'
```

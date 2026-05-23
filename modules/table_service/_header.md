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

## Eventual consistency on CORS read-back

The ARM `GET` on `tableServices/default` is eventually consistent for CORS:
immediately after a successful `PATCH`, a follow-up read can return without
the `corsRules` that were just applied, even though they are present in the
service. This causes the next `terraform plan` (and the post-apply
idempotency check that runs straight after `apply`) to see false drift on
`body.properties.cors`. In practice the read-back stabilises after roughly
two minutes.

To handle this, the submodule wires a `time_sleep` resource that waits after
the PATCH before allowing dependents to refresh. The wait duration is
configurable via the root module's `table_service_cors_propagation_wait`
variable (default `"2m"`). Set it to `"0s"` to disable the wait entirely —
this is not recommended when `cors_rules` is set, because subsequent plans
may show transient drift.

<!-- BEGIN_TF_DOCS -->
# File Service Submodule

This submodule configures file service properties for an Azure Storage Account using `azapi_update_resource` to PATCH `fileServices/default`.

**ARM Resource Type**: `Microsoft.Storage/storageAccounts/fileServices@2025-06-01`

## Features

- SMB protocol settings (authentication methods, channel encryption, Kerberos ticket encryption, multichannel, versions)
- Share delete (soft-delete) retention policy
- CORS rules (up to 5 rules)

## Usage

This submodule can be consumed directly, and it is also called by the root module when `file_service_properties` is set.

```hcl
module "storage_account" {
  source  = "Azure/avm-res-storage-storageaccount/azurerm"
  version = "<version>"

  # ... other configuration ...

  file_service_properties = {
    share_retention_policy = {
      enabled = true
      days    = 14
    }
    smb = {
      versions                        = ["SMB3.0", "SMB3.1.1"]
      authentication_types            = ["Kerberos"]
      channel_encryption_types        = ["AES-256-GCM"]
      kerberos_ticket_encryption_type = ["AES-256"]
      multichannel_enabled            = true
    }
  }
}
```

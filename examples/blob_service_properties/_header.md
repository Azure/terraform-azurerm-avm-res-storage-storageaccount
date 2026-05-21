# Blob service properties example

Deploys a StorageV2 storage account with blob service-level settings configured
via `var.blob_properties`:

- Blob versioning enabled.
- Blob change feed enabled.
- Blob soft-delete with a 14-day retention window.
- Container soft-delete with a 14-day retention window.

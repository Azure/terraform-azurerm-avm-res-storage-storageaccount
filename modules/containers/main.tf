resource "azapi_resource" "containers" {
  type = "Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01"
  body = {
    properties = {
      metadata                       = var.metadata
      publicAccess                   = var.public_access
      immutableStorageWithVersioning = var.immutable_storage_with_versioning
    }
  }
  name                      = var.name
  parent_id                 = "${var.storage_account.resource_id}/blobServices/default"
  schema_validation_enabled = false #https://github.com/Azure/terraform-provider-azapi/issues/497

}

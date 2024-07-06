# resource "azapi_resource" "containers" {
#   type = "Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01"
#   body = {
#     properties = {
#       metadata                       = each.value.metadata == null ? {} : each.value.metadata
#       publicAccess                   = each.value.public_access
#       immutableStorageWithVersioning = each.value.immutable_storage_with_versioning == "" ? {} : each.value.immutable_storage_with_versioning
#     }
#   }
#   name                      = each.value.name
#   parent_id                 = "${var.containers.azurerm_storage_account.this.id}/blobServices/default"
#   schema_validation_enabled = false #https://github.com/Azure/terraform-provider-azapi/issues/497

#   dynamic "timeouts" {
#     for_each = each.value.timeouts == null ? [] : [each.value.timeouts]
#     content {
#       create = timeouts.value.create
#       delete = timeouts.value.delete
#       read   = timeouts.value.read
#     }
#   }
# }

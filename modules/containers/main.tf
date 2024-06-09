resource "azapi_resource" "containers" {
  for_each = var.containers

  #type = "Microsoft.Storage/storageAccounts/blobServices/containers@2022-09-01"
  type = "mic"
  body = jsonencode({
    properties = {
      metadata     = each.value.metadata
      publicAccess = each.value.public_access
    }
  })
  name                      = each.value.name
  parent_id                 = "${azurerm_storage_account.this.id}/blobServices/default"
  schema_validation_enabled = false #https://github.com/Azure/terraform-provider-azapi/issues/497

  dynamic "timeouts" {
    for_each = each.value.timeouts == null ? [] : [each.value.timeouts]
    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
    }
  }
}

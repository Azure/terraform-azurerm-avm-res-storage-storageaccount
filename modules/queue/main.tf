resource "azapi_resource" "queue" {
  for_each = var.queues

  #type = "Microsoft.Storage/storageAccounts/queueServices/queues@2023-01-01"
type =


  body = jsonencode({
    properties = {
      # metadata = each.value.metadata
    }
  })
  name                      = each.value.name
  parent_id                 = "${azurerm_storage_account.this.id}/queueServices/default"
  schema_validation_enabled = false

  dynamic "timeouts" {
    for_each = each.value.timeouts == null ? [] : [each.value.timeouts]
    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
    }
  }
}


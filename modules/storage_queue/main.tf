resource "azapi_resource" "queue" {
  type = "Microsoft.Storage/storageAccounts/queueServices/queues@2023-01-01"
  body = jsonencode({
    properties = {
      metadata = each.value.metadata
    }
  })
  name                      = each.value.name
  parent_id                 = "${var.queues.storage_account_id}/queueServices/default"
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


# resource "azapi_resource" "queue" {
#   type = "Microsoft.Storage/storageAccounts/queueServices/queues@2023-01-01"
#   body = jsonencode({
#     properties = {
#       metadata = var.metadata
#     }
#   })
#   name                      = var.name
#   parent_id                 = "${var.storage_account_id}/queueServices/default"
#   schema_validation_enabled = false

#   dynamic "timeouts" {
#     for_each = var.timeouts == null ? [] : [var.timeouts]
#     content {
#       create = timeouts.value.create
#       delete = timeouts.value.delete
#       read   = timeouts.value.read
#     }
#   }
# }

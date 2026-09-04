resource "azapi_update_resource" "this" {
  resource_id = "${var.storage_account_id}/queueServices/default"
  type        = var.resource_type
  body        = local.resource_body
  retry       = var.retry

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]

    content {
      create = timeouts.value.create
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }
}

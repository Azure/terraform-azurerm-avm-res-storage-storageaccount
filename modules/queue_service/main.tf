resource "azapi_update_resource" "this" {
  resource_id    = "${var.storage_account_id}/queueServices/default"
  type           = var.resource_type
  body           = local.resource_body
  read_headers   = local.tracing_headers
  retry          = var.retry
  update_headers = local.tracing_headers

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]

    content {
      create = timeouts.value.create
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }
}

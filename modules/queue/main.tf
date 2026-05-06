locals {
  tracing_headers = var.tracing_tags_header == null ? null : { "User-Agent" = var.tracing_tags_header }
}

resource "azapi_resource" "this" {
  name      = var.name
  parent_id = "${var.storage_account_id}/queueServices/default"
  type      = "Microsoft.Storage/storageAccounts/queueServices/queues@2024-01-01"
  body = {
    properties = {
      metadata = var.metadata == null ? {} : var.metadata
    }
  }
  create_headers            = local.tracing_headers
  delete_headers            = local.tracing_headers
  read_headers              = local.tracing_headers
  retry                     = var.retry
  schema_validation_enabled = false
  update_headers            = local.tracing_headers

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }
}

module "role_assignments" {
  source = "../role_assignments"

  scope               = azapi_resource.this.id
  retry               = var.retry
  role_assignments    = var.role_assignments
  timeouts            = var.timeouts
  tracing_tags_header = var.tracing_tags_header
}

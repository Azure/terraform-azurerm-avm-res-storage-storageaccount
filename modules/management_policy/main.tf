resource "azapi_resource" "this" {
  name      = "default"
  parent_id = var.storage_account_id
  type      = var.resource_type
  body = {
    properties = {
      policy = {
        rules = local.arm_rules
      }
    }
  }
  create_headers         = local.tracing_headers
  delete_headers         = local.tracing_headers
  read_headers           = local.tracing_headers
  response_export_values = []
  retry                  = var.retry
  update_headers         = local.tracing_headers

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

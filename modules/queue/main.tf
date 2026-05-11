resource "azapi_resource" "this" {
  name      = var.name
  parent_id = "${var.storage_account_id}/queueServices/default"
  type      = var.resource_type
  body = {
    properties = {
      metadata = var.metadata == null ? {} : var.metadata
    }
  }
  create_headers            = local.tracing_headers
  delete_headers            = local.tracing_headers
  read_headers              = local.tracing_headers
  response_export_values    = []
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
  # tflint-ignore: required_module_source_tffr1 # relative source is intentional: this is an in-module composition of the role_assignments submodule
  source = "../role_assignments"

  scope                                     = azapi_resource.this.id
  retry                                     = var.retry
  role_assignment_definition_lookup_enabled = var.role_assignment_definition_lookup_enabled
  role_assignments                          = var.role_assignments
  timeouts                                  = var.timeouts
  tracing_tags_header                       = var.tracing_tags_header
}

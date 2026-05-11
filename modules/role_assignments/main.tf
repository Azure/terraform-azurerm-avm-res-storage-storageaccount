module "interfaces" {
  source  = "Azure/avm-utl-interfaces/azure"
  version = "0.6.0"

  enable_telemetry                          = false
  role_assignment_definition_lookup_enabled = var.role_assignment_definition_lookup_enabled
  role_assignment_definition_scope          = var.scope
  role_assignments                          = var.role_assignments
}

resource "azapi_resource" "this" {
  for_each = module.interfaces.role_assignments_azapi

  name                   = each.value.name
  parent_id              = var.scope
  type                   = each.value.type
  body                   = each.value.body
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

  lifecycle {
    # principalType is server-resolved (User/ServicePrincipal/Group) when not specified; ignore to avoid drift.
    ignore_changes = [body.properties.principalType]
  }
}

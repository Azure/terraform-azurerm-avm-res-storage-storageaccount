module "tables" {
  source   = "./modules/table"
  for_each = var.tables

  name                                      = each.value.name
  storage_account_id                        = azapi_resource.this.id
  resource_type                             = var.resource_types.table
  retry                                     = var.retry
  role_assignment_definition_lookup_enabled = var.role_assignment_definition_lookup_enabled
  role_assignments                          = each.value.role_assignments
  signed_identifiers                        = each.value.signed_identifiers
  timeouts                                  = each.value.timeouts != null ? each.value.timeouts : var.timeouts
  tracing_tags_header                       = var.enable_telemetry ? local.avm_azapi_header : null
}

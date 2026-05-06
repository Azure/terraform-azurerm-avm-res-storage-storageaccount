module "tables" {
  source   = "./modules/table"
  for_each = var.tables

  name                = each.value.name
  storage_account_id  = azapi_resource.this.id
  retry               = var.retry
  role_assignments    = each.value.role_assignments
  signed_identifiers  = each.value.signed_identifiers
  timeouts            = each.value.timeouts != null ? each.value.timeouts : var.timeouts
  tracing_tags_header = var.enable_telemetry ? local.avm_azapi_header : null
}

moved {
  from = azapi_resource.table
  to   = module.tables.azapi_resource.this
}

# Per-table role assignments are now created inside the table submodule.
# Migrate state from the historical root-level module to the nested module.
moved {
  from = module.table_role_assignments
  to   = module.tables.module.role_assignments
}

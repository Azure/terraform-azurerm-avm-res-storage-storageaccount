module "tables" {
  source   = "./modules/table"
  for_each = var.tables

  name                = each.value.name
  storage_account_id  = azapi_resource.this.id
  retry               = var.retry
  signed_identifiers  = each.value.signed_identifiers
  timeouts            = each.value.timeouts != null ? each.value.timeouts : var.timeouts
  tracing_tags_header = var.enable_telemetry ? local.avm_azapi_header : null
}

# Per-table role assignments. Created at the root because the table submodule
# does not (and per AVM lint cannot) embed the `role_assignments` submodule via
# a relative `../role_assignments` source.
module "table_role_assignments" {
  source   = "./modules/role_assignments"
  for_each = var.tables

  scope               = module.tables[each.key].resource_id
  retry               = var.retry
  role_assignments    = each.value.role_assignments
  timeouts            = each.value.timeouts != null ? each.value.timeouts : var.timeouts
  tracing_tags_header = var.enable_telemetry ? local.avm_azapi_header : null
}

moved {
  from = azapi_resource.table
  to   = module.tables.azapi_resource.this
}

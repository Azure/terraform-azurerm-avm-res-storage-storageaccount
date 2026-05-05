module "tables" {
  source   = "./modules/table"
  for_each = var.tables

  storage_account_id = azapi_resource.this.id
  name               = each.value.name
  signed_identifiers = each.value.signed_identifiers

  role_assignments    = each.value.role_assignments
  retry               = var.retry
  timeouts            = each.value.timeouts != null ? each.value.timeouts : var.timeouts
  tracing_tags_header = var.enable_telemetry ? local.avm_azapi_header : null
}

moved {
  from = azapi_resource.table
  to   = module.tables.azapi_resource.this
}

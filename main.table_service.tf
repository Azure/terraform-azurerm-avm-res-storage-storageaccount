module "table_service" {
  source = "./modules/table_service"
  count  = var.table_properties != null ? 1 : 0

  storage_account_id  = azapi_resource.this.id
  table_properties    = var.table_properties
  resource_type       = var.resource_types.table_service
  retry               = var.retry
  timeouts            = var.timeouts
  tracing_tags_header = var.enable_telemetry ? local.avm_azapi_header : null
}

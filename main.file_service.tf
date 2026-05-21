module "file_service" {
  source = "./modules/file_service"
  count  = var.file_service_properties != null ? 1 : 0

  storage_account_id      = azapi_resource.this.id
  file_service_properties = var.file_service_properties
  resource_type           = var.resource_types.file_service
  retry                   = var.retry
  timeouts                = var.timeouts
  tracing_tags_header     = var.enable_telemetry ? local.avm_azapi_header : null
}

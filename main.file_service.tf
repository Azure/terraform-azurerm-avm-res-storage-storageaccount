module "file_service" {
  source = "./modules/file_service"
  count  = var.file_service_properties != null ? 1 : 0

  file_service_properties = var.file_service_properties
  location                = var.location
  storage_account_id      = azapi_resource.this.id
  enable_telemetry        = var.enable_telemetry
  resource_type           = var.resource_types.file_service
  retry                   = var.retry
  timeouts                = var.timeouts
}

module "blob_service" {
  source = "./modules/blob_service"
  count  = var.blob_properties != null ? 1 : 0

  blob_properties    = var.blob_properties
  location           = var.location
  storage_account_id = azapi_resource.this.id
  enable_telemetry   = var.enable_telemetry
  resource_type      = var.resource_types.blob_service
  retry              = var.retry
  timeouts           = var.timeouts
}

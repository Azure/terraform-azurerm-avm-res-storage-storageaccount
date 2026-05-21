module "blob_service" {
  source = "./modules/blob_service"
  count  = var.blob_properties != null ? 1 : 0

  blob_properties     = var.blob_properties
  storage_account_id  = azapi_resource.this.id
  resource_type       = var.resource_types.blob_service
  retry               = var.retry
  timeouts            = var.timeouts
  tracing_tags_header = var.enable_telemetry ? local.avm_azapi_header : null
}

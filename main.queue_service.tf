module "queue_service" {
  source = "./modules/queue_service"
  count  = var.queue_properties != null ? 1 : 0

  storage_account_id  = azapi_resource.this.id
  queue_properties    = var.queue_properties
  resource_type       = var.resource_types.queue_service
  retry               = var.retry
  timeouts            = var.timeouts
  tracing_tags_header = var.enable_telemetry ? local.avm_azapi_header : null
}

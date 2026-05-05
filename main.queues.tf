module "queues" {
  source   = "./modules/queue"
  for_each = var.queues

  storage_account_id = azapi_resource.this.id
  name               = each.value.name
  metadata           = each.value.metadata

  role_assignments    = each.value.role_assignments
  retry               = var.retry
  timeouts            = each.value.timeouts != null ? each.value.timeouts : var.timeouts
  tracing_tags_header = var.enable_telemetry ? local.avm_azapi_header : null
}

moved {
  from = azapi_resource.queue
  to   = module.queues.azapi_resource.this
}

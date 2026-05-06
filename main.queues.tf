module "queues" {
  source   = "./modules/queue"
  for_each = var.queues

  name                = each.value.name
  storage_account_id  = azapi_resource.this.id
  metadata            = each.value.metadata
  retry               = var.retry
  role_assignments    = each.value.role_assignments
  timeouts            = each.value.timeouts != null ? each.value.timeouts : var.timeouts
  tracing_tags_header = var.enable_telemetry ? local.avm_azapi_header : null
}

moved {
  from = azapi_resource.queue
  to   = module.queues.azapi_resource.this
}

# Per-queue role assignments are now created inside the queue submodule.
# Migrate state from the historical root-level module to the nested module.
moved {
  from = module.queue_role_assignments
  to   = module.queues.module.role_assignments
}

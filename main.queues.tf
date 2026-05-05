module "queues" {
  source   = "./modules/queue"
  for_each = var.queues

  name                = each.value.name
  storage_account_id  = azapi_resource.this.id
  metadata            = each.value.metadata
  retry               = var.retry
  timeouts            = each.value.timeouts != null ? each.value.timeouts : var.timeouts
  tracing_tags_header = var.enable_telemetry ? local.avm_azapi_header : null
}

# Per-queue role assignments. Created at the root because the queue submodule
# does not (and per AVM lint cannot) embed the `role_assignments` submodule via
# a relative `../role_assignments` source.
module "queue_role_assignments" {
  source   = "./modules/role_assignments"
  for_each = var.queues

  scope               = module.queues[each.key].resource_id
  retry               = var.retry
  role_assignments    = each.value.role_assignments
  timeouts            = each.value.timeouts != null ? each.value.timeouts : var.timeouts
  tracing_tags_header = var.enable_telemetry ? local.avm_azapi_header : null
}

moved {
  from = azapi_resource.queue
  to   = module.queues.azapi_resource.this
}

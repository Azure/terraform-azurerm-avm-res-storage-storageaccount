module "queues" {
  source   = "./modules/queue"
  for_each = var.queues

  name                                      = each.value.name
  storage_account_id                        = azapi_resource.this.id
  metadata                                  = each.value.metadata
  resource_type                             = var.resource_types.queue
  retry                                     = var.retry
  role_assignment_definition_lookup_enabled = var.role_assignment_definition_lookup_enabled
  role_assignments                          = each.value.role_assignments
  timeouts                                  = each.value.timeouts != null ? each.value.timeouts : var.timeouts
  tracing_tags_header                       = var.enable_telemetry ? local.avm_azapi_header : null
}

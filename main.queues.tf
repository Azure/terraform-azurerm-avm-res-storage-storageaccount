module "queues" {
  source = "./modules/queue"
  providers = {
    azapi = azapi
  }
  for_each = var.queues

  location                                  = var.location
  name                                      = each.value.name
  storage_account_id                        = azapi_resource.this.id
  enable_telemetry                          = var.enable_telemetry
  metadata                                  = each.value.metadata
  resource_type                             = var.resource_types.queue
  retry                                     = var.retry
  role_assignment_definition_lookup_enabled = var.role_assignment_definition_lookup_enabled
  role_assignments                          = each.value.role_assignments
  timeouts                                  = each.value.timeouts != null ? each.value.timeouts : var.timeouts
}

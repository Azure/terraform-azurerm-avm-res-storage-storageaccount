module "management_policy" {
  source = "./modules/management_policy"
  count  = local.has_management_policy ? 1 : 0

  rules               = var.storage_management_policy_rule
  storage_account_id  = azapi_resource.this.id
  retry               = var.retry
  timeouts            = var.storage_management_policy_timeouts != null ? var.storage_management_policy_timeouts : var.timeouts
  tracing_tags_header = var.enable_telemetry ? local.avm_azapi_header : null
}

moved {
  from = azurerm_storage_management_policy.this[0]
  to   = module.management_policy[0].azapi_resource.this
}

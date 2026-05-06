module "shares" {
  source   = "./modules/share"
  for_each = var.shares

  name                = each.value.name
  quota               = each.value.quota
  storage_account_id  = azapi_resource.this.id
  access_tier         = each.value.access_tier
  enabled_protocol    = each.value.enabled_protocol
  metadata            = each.value.metadata
  retry               = var.retry
  role_assignments    = each.value.role_assignments
  root_squash         = each.value.root_squash
  signed_identifiers  = each.value.signed_identifiers
  timeouts            = each.value.timeouts != null ? each.value.timeouts : var.timeouts
  tracing_tags_header = var.enable_telemetry ? local.avm_azapi_header : null
}

moved {
  from = azapi_resource.share
  to   = module.shares.azapi_resource.this
}

# Per-share role assignments are now created inside the share submodule.
# Migrate state from the historical root-level module to the nested module.
moved {
  from = module.share_role_assignments
  to   = module.shares.module.role_assignments
}

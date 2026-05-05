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
  root_squash         = each.value.root_squash
  signed_identifiers  = each.value.signed_identifiers
  timeouts            = each.value.timeouts != null ? each.value.timeouts : var.timeouts
  tracing_tags_header = var.enable_telemetry ? local.avm_azapi_header : null
}

# Per-share role assignments. Created at the root because the share submodule
# does not (and per AVM lint cannot) embed the `role_assignments` submodule via
# a relative `../role_assignments` source.
module "share_role_assignments" {
  source   = "./modules/role_assignments"
  for_each = var.shares

  scope               = module.shares[each.key].resource_id
  retry               = var.retry
  role_assignments    = each.value.role_assignments
  timeouts            = each.value.timeouts != null ? each.value.timeouts : var.timeouts
  tracing_tags_header = var.enable_telemetry ? local.avm_azapi_header : null
}

moved {
  from = azapi_resource.share
  to   = module.shares.azapi_resource.this
}

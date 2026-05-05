module "shares" {
  source   = "./modules/share"
  for_each = var.shares

  storage_account_id = azapi_resource.this.id
  name               = each.value.name
  access_tier        = each.value.access_tier
  enabled_protocol   = each.value.enabled_protocol
  metadata           = each.value.metadata
  quota              = each.value.quota
  root_squash        = each.value.root_squash
  signed_identifiers = each.value.signed_identifiers

  role_assignments    = each.value.role_assignments
  retry               = var.retry
  timeouts            = each.value.timeouts != null ? each.value.timeouts : var.timeouts
  tracing_tags_header = var.enable_telemetry ? local.avm_azapi_header : null
}

moved {
  from = azapi_resource.share
  to   = module.shares.azapi_resource.this
}

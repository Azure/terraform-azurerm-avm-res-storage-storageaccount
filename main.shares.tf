module "shares" {
  source   = "./modules/share"
  for_each = var.shares

  name                                      = each.value.name
  quota                                     = each.value.quota
  storage_account_id                        = azapi_resource.this.id
  access_tier                               = each.value.access_tier
  enabled_protocol                          = each.value.enabled_protocol
  metadata                                  = each.value.metadata
  resource_type                             = var.resource_types.share
  retry                                     = var.retry
  role_assignment_definition_lookup_enabled = var.role_assignment_definition_lookup_enabled
  role_assignments                          = each.value.role_assignments
  root_squash                               = each.value.root_squash
  signed_identifiers                        = each.value.signed_identifiers
  timeouts                                  = each.value.timeouts != null ? each.value.timeouts : var.timeouts
  tracing_tags_header                       = var.enable_telemetry ? local.avm_azapi_header : null
}

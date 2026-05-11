module "containers" {
  source   = "./modules/container"
  for_each = var.containers

  name                              = each.value.name
  storage_account_id                = azapi_resource.this.id
  default_encryption_scope          = each.value.default_encryption_scope
  deny_encryption_scope_override    = each.value.deny_encryption_scope_override
  enable_nfs_v3_all_squash          = each.value.enable_nfs_v3_all_squash
  enable_nfs_v3_root_squash         = each.value.enable_nfs_v3_root_squash
  immutable_storage_with_versioning = each.value.immutable_storage_with_versioning
  metadata                          = each.value.metadata
  public_access                     = each.value.public_access
  retry                             = var.retry
  role_assignments                  = each.value.role_assignments
  timeouts                          = each.value.timeouts != null ? each.value.timeouts : var.timeouts
  tracing_tags_header               = var.enable_telemetry ? local.avm_azapi_header : null
}

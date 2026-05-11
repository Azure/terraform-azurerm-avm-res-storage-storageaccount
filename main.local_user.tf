module "local_users" {
  source   = "./modules/local_user"
  for_each = var.local_user

  name                 = each.value.name
  storage_account_id   = azapi_resource.this.id
  home_directory       = each.value.home_directory
  permission_scope     = each.value.permission_scope
  resource_type        = var.resource_types.local_user
  retry                = var.retry
  ssh_authorized_key   = each.value.ssh_authorized_key
  ssh_key_enabled      = each.value.ssh_key_enabled == null ? false : each.value.ssh_key_enabled
  ssh_password_enabled = each.value.ssh_password_enabled == null ? false : each.value.ssh_password_enabled
  timeouts             = each.value.timeouts != null ? each.value.timeouts : var.timeouts
  tracing_tags_header  = var.enable_telemetry ? local.avm_azapi_header : null
}

module "local_users" {
  source   = "./modules/local_user"
  for_each = var.local_user

  storage_account_id   = azapi_resource.this.id
  name                 = each.value.name
  home_directory       = each.value.home_directory
  ssh_key_enabled      = each.value.ssh_key_enabled == null ? false : each.value.ssh_key_enabled
  ssh_password_enabled = each.value.ssh_password_enabled == null ? false : each.value.ssh_password_enabled
  permission_scope     = each.value.permission_scope
  ssh_authorized_key   = each.value.ssh_authorized_key

  retry               = var.retry
  timeouts            = each.value.timeouts != null ? each.value.timeouts : var.timeouts
  tracing_tags_header = var.enable_telemetry ? local.avm_azapi_header : null
}

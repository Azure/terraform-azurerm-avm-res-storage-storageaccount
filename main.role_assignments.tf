# Storage account-scope role assignments (var.role_assignments).
#
# v1.0.0 BREAKING CHANGE: Role assignments are now created via the
# `role_assignments` submodule and resolve role-definition IDs by name through
# AzAPI rather than the data sources used by the azurerm provider. Resource
# names (the ARM `name` segment of a roleAssignment) are now deterministic
# UUIDv5 hashes derived from `<scope>|<principal_id>|<role_definition_id>`
# instead of random GUIDs. Consumers upgrading from v0.x will need to either
# accept that role assignments are recreated (the underlying RBAC tuple is
# unchanged so callers retain access) or run `terraform state rm` for the old
# `azurerm_role_assignment.*` addresses prior to apply.
module "role_assignments" {
  source = "./modules/role_assignments"

  scope               = azapi_resource.this.id
  retry               = var.retry
  role_assignments    = var.role_assignments
  timeouts            = var.timeouts
  tracing_tags_header = var.enable_telemetry ? local.avm_azapi_header : null
}

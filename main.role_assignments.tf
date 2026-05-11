# Storage account-scope role assignments (var.role_assignments).
#
# v1.0.0 BREAKING CHANGE: Role assignments are now created via the
# `role_assignments` submodule, which composes `Azure/avm-utl-interfaces/azure`
# to resolve role-definition IDs by name and to construct the AzAPI body. The
# resulting `Microsoft.Authorization/roleAssignments` resources have new state
# addresses (`module.role_assignments.azapi_resource.this["<key>"]`) and new
# random GUID names supplied by the interfaces module. Consumers upgrading
# from v0.x must either accept that role assignments are recreated (the
# underlying RBAC tuple is unchanged so callers retain access) or run
# `terraform state rm` for the old `azurerm_role_assignment.*` addresses
# prior to apply.
module "role_assignments" {
  source = "./modules/role_assignments"

  scope               = azapi_resource.this.id
  retry               = var.retry
  role_assignments    = var.role_assignments
  timeouts            = var.timeouts
  tracing_tags_header = var.enable_telemetry ? local.avm_azapi_header : null
}

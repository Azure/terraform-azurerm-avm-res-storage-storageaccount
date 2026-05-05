# Data Lake Gen2 filesystems on the storage account.
#
# v1.0.0 BREAKING CHANGE: Only control-plane properties (name, default
# encryption scope, metadata) are managed by this module. The data-plane
# features previously available through the azurerm provider — `owner`,
# `group`, `properties` (filesystem metadata at root) and `ace` (POSIX ACLs)
# on the filesystem; and the `storage_data_lake_gen2_paths` resource — are no
# longer supported because the AzAPI provider does not exercise the DFS
# data-plane API. Manage those features externally if required (see the
# `examples/data_lake_gen2/` example for a recipe using the azurerm provider
# alongside this module).
module "data_lake_filesystems" {
  source   = "./modules/data_lake_filesystem"
  for_each = var.storage_data_lake_gen2_filesystems

  storage_account_id       = azapi_resource.this.id
  name                     = each.value.name
  default_encryption_scope = each.value.default_encryption_scope
  metadata                 = each.value.properties

  retry               = var.retry
  timeouts            = each.value.timeouts != null ? each.value.timeouts : var.timeouts
  tracing_tags_header = var.enable_telemetry ? local.avm_azapi_header : null
}

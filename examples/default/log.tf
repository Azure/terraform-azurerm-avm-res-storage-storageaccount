resource "azurerm_log_analytics_workspace" "this" {
  location            = azurerm_resource_group.this.location
  name                = "storage-account"
  resource_group_name = azurerm_resource_group.this.name
  retention_in_days   = 30
  sku                 = "PerGB2018"
}

resource "azurerm_log_analytics_storage_insights" "this" {
  name                 = "storageinsight"
  resource_group_name  = azurerm_resource_group.this.name
  storage_account_id   = module.this.storage_account_id
  storage_account_key  = module.this.storage_account_primary_access_key
  workspace_id         = azurerm_log_analytics_workspace.this.id
  blob_container_names = [for c in module.this.storage_container : c.name]
  table_names          = [for t in module.this.storage_table : t.name]

  depends_on = [module.this]
}
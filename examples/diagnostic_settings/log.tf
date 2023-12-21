resource "azurerm_log_analytics_workspace" "this" {
  location            = azurerm_resource_group.this.location
  name                = module.naming.log_analytics_workspace.name_unique
  resource_group_name = azurerm_resource_group.this.name
  sku                 = "PerGB2018"
}

resource "azurerm_log_analytics_storage_insights" "this" {
  name                 = "si-${module.naming.log_analytics_workspace.name_unique}"
  resource_group_name  = azurerm_resource_group.this.name
  storage_account_id   = module.this.id
  storage_account_key  = module.this.resource.primary_access_key
  workspace_id         = azurerm_log_analytics_workspace.this.id
  blob_container_names = [for c in module.this.containers : c.name]
  table_names          = [for t in module.this.tables : t.name]

  depends_on = [module.this]
}

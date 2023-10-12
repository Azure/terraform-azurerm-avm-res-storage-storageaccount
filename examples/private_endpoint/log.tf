resource "azurerm_log_analytics_workspace" "this" {
  location            = azurerm_resource_group.this.location
  name                = "storage-account"
  resource_group_name = azurerm_resource_group.this.name
  retention_in_days   = 30
  sku                 = "PerGB2018"
}
/*
resource "azurerm_log_analytics_storage_insights" "another_account" {
  name                 = "anotherstorageinsight"
  resource_group_name  = azurerm_resource_group.this.name
  storage_account_id   = module.another_container.storage_account_id
  storage_account_key  = module.another_container.storage_account_primary_access_key
  workspace_id         = azurerm_log_analytics_workspace.this.id
  blob_container_names = [for c in module.another_container.storage_container : c.name]

  depends_on = [module.another_container]
}
*/

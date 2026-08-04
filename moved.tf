# State migrations for resources whose old and new addresses can be mapped
# statically. The collection resources moved into for_each child modules in
# v0.7.0 require caller-specific moves, as documented in the README.
moved {
  from = azurerm_storage_account.this
  to   = azapi_resource.this
}

moved {
  from = azurerm_management_lock.this_storage_account[0]
  to   = azapi_resource.lock[0]
}

moved {
  from = azurerm_storage_management_policy.this[0]
  to   = module.management_policy[0].azapi_resource.this
}

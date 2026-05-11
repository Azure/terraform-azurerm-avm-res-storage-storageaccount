# Centralised state-migration `moved` blocks. All resources that were
# previously named differently (or were managed by the azurerm provider before
# the v1.0.0 azapi conversion) point to their current address here so existing
# state migrates without forcing a destroy/create.
moved {
  from = azurerm_storage_account.this
  to   = azapi_resource.this
}

moved {
  from = azurerm_management_lock.this_storage_account[0]
  to   = azapi_resource.lock[0]
}

moved {
  from = azapi_resource.containers
  to   = module.containers.azapi_resource.this
}

moved {
  from = azurerm_storage_management_policy.this[0]
  to   = module.management_policy[0].azapi_resource.this
}

moved {
  from = azapi_resource.queue
  to   = module.queues.azapi_resource.this
}

moved {
  from = azapi_resource.share
  to   = module.shares.azapi_resource.this
}

moved {
  from = azapi_resource.table
  to   = module.tables.azapi_resource.this
}

removed {
  from = azurerm_storage_account_network_rules.this
  lifecycle {
    detroy = false
  }
}

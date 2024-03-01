# Resource Block for Locks for storage account
resource "azurerm_management_lock" "this_storage_account" {
  count = var.lock.kind != "None" ? 1 : 0

  lock_level = var.lock.kind
  name       = coalesce(var.lock.name, "lock-${var.name}")
  scope      = azurerm_storage_account.this.id

  depends_on = [
    azurerm_storage_account.this
  ]
}

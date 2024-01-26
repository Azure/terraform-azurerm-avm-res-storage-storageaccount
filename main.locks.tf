# Resource Block for Locks #TODO Should complete the locks with dependant resources.
resource "azurerm_management_lock" "this-storage_account" {
  count = var.lock.kind != "None" ? 1 : 0

  lock_level = var.lock.kind
  name       = coalesce(var.lock.name, "lock-${var.name}")
  scope      = azurerm_storage_account.this.id

  depends_on = [
    azurerm_storage_account.this
  ]
}

resource "azurerm_management_lock" "pe" {
  for_each = { for private_endpoint, pe_values in var.private_endpoints : private_endpoint => pe_values if((pe_values.inherit_lock && var.lock.kind != "None") || pe_values.lock.kind != "None") }

  name       = each.value.lock.name != null ? each.value.lock.name : (each.value.name != null ? "lock-${each.value.name}" : "lock-pe-${var.name}")
  scope      = azurerm_private_endpoint.this[each.key].id
  lock_level = each.value.inherit_lock ? var.lock.kind : each.value.lock.kind
  depends_on = [
    azurerm_storage_account.this,
    azurerm_private_endpoint.this,
    azurerm_role_assignment.storage_account,
  ]
}

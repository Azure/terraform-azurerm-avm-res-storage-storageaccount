resource "azurerm_storage_data_lake_gen2_filesystem" "this" {
  for_each = var.storage_data_lake_gen2_filesystem

  name                     = each.value.name
  storage_account_id       = azurerm_storage_account.this.id
  default_encryption_scope = each.value.default_encryption_scope
  group                    = each.value.group
  owner                    = each.value.owner
  properties               = each.value.properties

  dynamic "ace" {
    for_each = each.value.ace == null ? [] : each.value.ace

    content {
      permissions = each.value.permissions
      type        = each.value.type
      id          = each.value.id
      scope       = each.value.scope
    }
  }
  dynamic "timeouts" {
    for_each = each.value.timeouts == null ? [] : [each.value.timeouts]

    content {
      create = each.value.create
      delete = each.value.delete
      read   = each.value.read
      update = each.value.update
    }
  }

  depends_on = [azurerm_storage_account.this]
}


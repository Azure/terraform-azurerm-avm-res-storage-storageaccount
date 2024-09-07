resource "azurerm_storage_data_lake_gen2_filesystem" "this" {
  count = var.storage_data_lake_gen2_filesystem != null ? 1 : 0

  name                     = var.storage_data_lake_gen2_filesystem.name
  storage_account_id       = azurerm_storage_account.this.id
  default_encryption_scope = var.storage_data_lake_gen2_filesystem.default_encryption_scope
  group                    = var.storage_data_lake_gen2_filesystem.group
  owner                    = var.storage_data_lake_gen2_filesystem.owner
  properties               = var.storage_data_lake_gen2_filesystem.properties

  dynamic "ace" {
    for_each = var.storage_data_lake_gen2_filesystem.ace == null ? [] : var.storage_data_lake_gen2_filesystem.ace

    content {
      permissions = ace.value.permissions
      type        = ace.value.type
      id          = ace.value.id
      scope       = ace.value.scope
    }
  }
  dynamic "timeouts" {
    for_each = var.storage_data_lake_gen2_filesystem.timeouts == null ? [] : [var.storage_data_lake_gen2_filesystem.timeouts]

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }

  depends_on = [azurerm_storage_account.this]
}


resource "azurerm_storage_data_lake_gen2_filesystem" "this" {
  count = var.storage_data_lake_gen2_filesystem_name != null ? 1 : 0
  name                     = var.storage_data_lake_gen2_filesystem_name
  storage_account_id       = var.storage_data_lake_gen2_filesystem_storage_account_id
  default_encryption_scope = var.storage_data_lake_gen2_filesystem_default_encryption_scope
  group                    = var.storage_data_lake_gen2_filesystem_group
  owner                    = var.storage_data_lake_gen2_filesystem_owner
  properties               = var.storage_data_lake_gen2_filesystem_properties

  dynamic "ace" {
    for_each = var.storage_data_lake_gen2_filesystem_ace == null ? [] : var.storage_data_lake_gen2_filesystem_ace
    content {
      permissions = ace.value.permissions
      type        = ace.value.type
      id          = ace.value.id
      scope       = ace.value.scope
    }
  }
  dynamic "timeouts" {
    for_each = var.storage_data_lake_gen2_filesystem_timeouts == null ? [] : [var.storage_data_lake_gen2_filesystem_timeouts]
    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }
}


moved {
  from = azurerm_storage_data_lake_gen2_filesystem.this[0]
  to   = azurerm_storage_data_lake_gen2_filesystem.this["legacy"]
}

locals {
  storage_data_lake_gen2_filesystems = merge(
    var.storage_data_lake_gen2_filesystem == null ? {} : { legacy = var.storage_data_lake_gen2_filesystem },
    var.storage_data_lake_gen2_filesystems
  )
}

resource "azurerm_storage_data_lake_gen2_filesystem" "this" {
  for_each = local.storage_data_lake_gen2_filesystems

  name                     = each.value.name
  storage_account_id       = azurerm_storage_account.this.id
  default_encryption_scope = each.value.default_encryption_scope
  group                    = each.value.group
  owner                    = each.value.owner
  properties               = each.value.properties

  dynamic "ace" {
    for_each = each.value.ace == null ? [] : each.value.ace

    content {
      permissions = ace.value.permissions
      type        = ace.value.type
      id          = ace.value.id
      scope       = ace.value.scope
    }
  }
  dynamic "timeouts" {
    for_each = each.value.timeouts == null ? [] : [each.value.timeouts]

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }

  depends_on = [azurerm_storage_account.this]
}

# Wait for role assignments to propagate before creating paths with ACLs
resource "time_sleep" "wait_for_rbac" {
  create_duration = "60s"

  depends_on = [azurerm_role_assignment.storage_account]
}

resource "azurerm_storage_data_lake_gen2_path" "this" {
  for_each = var.storage_data_lake_gen2_paths

  filesystem_name    = each.value.filesystem_name
  path               = each.value.path
  resource           = each.value.resource
  storage_account_id = azurerm_storage_account.this.id
  group              = each.value.group
  owner              = each.value.owner

  dynamic "ace" {
    for_each = each.value.ace == null ? [] : each.value.ace

    content {
      permissions = ace.value.permissions
      type        = ace.value.type
      id          = ace.value.id
      scope       = ace.value.scope
    }
  }
  dynamic "timeouts" {
    for_each = each.value.timeouts == null ? [] : [each.value.timeouts]

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }

  depends_on = [
    azurerm_storage_data_lake_gen2_filesystem.this,
    time_sleep.wait_for_rbac
  ]
}

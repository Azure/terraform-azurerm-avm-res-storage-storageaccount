resource "azurerm_storage_table" "this" {
  for_each = var.tables

  name                 = each.value.name
  storage_account_name = azurerm_storage_account.this.name

  dynamic "acl" {
    for_each = each.value.acl == null ? [] : each.value.acl
    content {
      id = acl.value.id

      dynamic "access_policy" {
        for_each = acl.value.access_policy == null ? [] : acl.value.access_policy
        content {
          expiry      = access_policy.value.expiry
          permissions = access_policy.value.permissions
          start       = access_policy.value.start
        }
      }
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

  # We need to create these storage service in serialize otherwise we might meet dns issue
  depends_on = [azapi_resource.containers, azurerm_storage_queue.this, time_sleep.wait_for_rbac_before_table_operations]
}

# Enable role assignments for tables
resource "azurerm_role_assignment" "tables" {
  for_each = local.tables_role_assignments

  principal_id = each.value.role_assignment.principal_id
  # the resource manager id is not exposed directly by the AzureRM provider - https://github.com/hashicorp/terraform-provider-azurerm/issues/21525
  scope                                  = "${azurerm_storage_account.this.id}/tableServices/default/tables/${azurerm_storage_table.this[each.value.table_key].name}"
  condition                              = each.value.role_assignment.condition
  condition_version                      = each.value.role_assignment.condition_version
  delegated_managed_identity_resource_id = each.value.role_assignment.delegated_managed_identity_resource_id
  role_definition_id                     = strcontains(lower(each.value.role_assignment.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? each.value.role_assignment.role_definition_id_or_name : null
  role_definition_name                   = strcontains(lower(each.value.role_assignment.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? null : each.value.role_assignment.role_definition_id_or_name
  skip_service_principal_aad_check       = each.value.role_assignment.skip_service_principal_aad_check
}

resource "time_sleep" "wait_for_rbac_before_table_operations" {
  count = length(var.role_assignments) > 0 && length(var.tables) > 0 ? 1 : 0

  create_duration  = var.wait_for_rbac_before_table_operations.create
  destroy_duration = var.wait_for_rbac_before_table_operations.destroy
  triggers = {
    role_assignments = jsonencode(var.role_assignments)
  }

  depends_on = [
    azurerm_role_assignment.storage_account
  ]
}

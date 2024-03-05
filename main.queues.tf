resource "azurerm_storage_queue" "this" {
  for_each = var.queues

  name                 = each.value.name
  storage_account_name = azurerm_storage_account.this.name
  metadata             = each.value.metadata

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
  depends_on = [azapi_resource.containers, time_sleep.wait_for_rbac_before_queue_operations, azurerm_storage_account.this]
}

# Enable role assignments for queues
resource "azurerm_role_assignment" "queues" {
  for_each = local.queues_role_assignments

  principal_id                           = each.value.role_assignment.principal_id
  scope                                  = azurerm_storage_queue.this[each.value.queue_key].resource_manager_id
  condition                              = each.value.role_assignment.condition
  condition_version                      = each.value.role_assignment.condition_version
  delegated_managed_identity_resource_id = each.value.role_assignment.delegated_managed_identity_resource_id
  role_definition_id                     = strcontains(lower(each.value.role_assignment.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? each.value.role_assignment.role_definition_id_or_name : null
  role_definition_name                   = strcontains(lower(each.value.role_assignment.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? null : each.value.role_assignment.role_definition_id_or_name
  skip_service_principal_aad_check       = each.value.role_assignment.skip_service_principal_aad_check
}

resource "time_sleep" "wait_for_rbac_before_queue_operations" {
  count = length(var.role_assignments) > 0 && length(var.queues) > 0 ? 1 : 0

  create_duration  = var.wait_for_rbac_before_queue_operations.create
  destroy_duration = var.wait_for_rbac_before_queue_operations.destroy
  triggers = {
    role_assignments = jsonencode(var.role_assignments)
  }

  depends_on = [
    azurerm_role_assignment.storage_account
  ]
}

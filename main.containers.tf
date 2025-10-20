# This uses azapi in order to avoid having to grant data plane permissions
resource "azapi_resource" "containers" {
  for_each = var.containers

  name      = each.value.name
  parent_id = "${azurerm_storage_account.this.id}/blobServices/default"
  type      = "Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01"
  body = {
    properties = {
      metadata                       = each.value.metadata == null ? {} : each.value.metadata
      publicAccess                   = each.value.public_access
      immutableStorageWithVersioning = each.value.immutable_storage_with_versioning == "" ? {} : each.value.immutable_storage_with_versioning
    }
  }
  create_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers   = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  update_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null

  dynamic "timeouts" {
    for_each = each.value.timeouts == null ? [] : [each.value.timeouts]

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
    }
  }
}

# Enable role assignments for containers
resource "azurerm_role_assignment" "containers" {
  for_each = local.containers_role_assignments

  principal_id                           = each.value.role_assignment.principal_id
  scope                                  = azapi_resource.containers[each.value.container_key].id
  condition                              = each.value.role_assignment.condition
  condition_version                      = each.value.role_assignment.condition_version
  delegated_managed_identity_resource_id = each.value.role_assignment.delegated_managed_identity_resource_id
  principal_type                         = each.value.role_assignment.principal_type
  role_definition_id                     = strcontains(lower(each.value.role_assignment.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? each.value.role_assignment.role_definition_id_or_name : null
  role_definition_name                   = strcontains(lower(each.value.role_assignment.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? null : each.value.role_assignment.role_definition_id_or_name
  skip_service_principal_aad_check       = each.value.role_assignment.skip_service_principal_aad_check
}

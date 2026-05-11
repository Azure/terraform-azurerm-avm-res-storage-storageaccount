resource "azapi_resource" "table" {
  for_each = var.tables

  name      = each.value.name
  parent_id = "${azurerm_storage_account.this.id}/tableServices/default"
  type      = "Microsoft.Storage/storageAccounts/tableServices/tables@2023-01-01"
  body = {
    properties = {
      signedIdentifiers = [
        for signed_identifier in each.value.signed_identifiers : {
          id = signed_identifier.id
          accessPolicy = signed_identifier.access_policy == null ? null : {
            expiryTime = signed_identifier.access_policy.expiry_time
            permission = signed_identifier.access_policy.permission
            startTime  = signed_identifier.access_policy.start_time
          }
      }]
    }
  }
  create_headers            = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers            = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers              = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  schema_validation_enabled = true
  update_headers            = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null

  dynamic "timeouts" {
    for_each = each.value.timeouts == null ? [] : [each.value.timeouts]

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
    }
  }
}

# Enable role assignments for tables
resource "azurerm_role_assignment" "tables" {
  for_each = local.tables_role_assignments

  principal_id = each.value.role_assignment.principal_id
  # the resource manager id is not exposed directly by the AzureRM provider - https://github.com/hashicorp/terraform-provider-azurerm/issues/21525
  scope                                  = "${azurerm_storage_account.this.id}/tableServices/default/tables/${azapi_resource.table[each.value.table_key].name}"
  condition                              = each.value.role_assignment.condition
  condition_version                      = each.value.role_assignment.condition_version
  delegated_managed_identity_resource_id = each.value.role_assignment.delegated_managed_identity_resource_id
  principal_type                         = each.value.role_assignment.principal_type
  role_definition_id                     = strcontains(lower(each.value.role_assignment.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? each.value.role_assignment.role_definition_id_or_name : null
  role_definition_name                   = strcontains(lower(each.value.role_assignment.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? null : each.value.role_assignment.role_definition_id_or_name
  skip_service_principal_aad_check       = each.value.role_assignment.skip_service_principal_aad_check
}


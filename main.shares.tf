resource "azapi_resource" "share" {
  for_each = var.shares

  type = "Microsoft.Storage/storageAccounts/fileServices/shares@2023-01-01"
  body = {
    properties = {
      metadata          = each.value.metadata
      access_tier       = each.value.access_tier
      enabledProtocols  = each.value.enabled_protocol
      shareQuota        = each.value.quota
      rootSquash        = each.value.root_squash
      signedIdentifiers = each.value.signed_identifiers == null ? [] : each.value.signed_identifiers


    }
  }
  name                      = each.value.name
  parent_id                 = "${azurerm_storage_account.this.id}/fileServices/default"
  schema_validation_enabled = false

  dynamic "timeouts" {
    for_each = each.value.timeouts == null ? [] : [each.value.timeouts]

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
    }
  }
}

# Enable role assignments for shares
resource "azurerm_role_assignment" "shares" {
  for_each = local.shares_role_assignments

  principal_id                           = each.value.role_assignment.principal_id
  scope                                  = "${azurerm_storage_account.this.id}/fileServices/default/shares/${azapi_resource.share[each.value.share_key].name}"
  condition                              = each.value.role_assignment.condition
  condition_version                      = each.value.role_assignment.condition_version
  delegated_managed_identity_resource_id = each.value.role_assignment.delegated_managed_identity_resource_id
  role_definition_id                     = strcontains(lower(each.value.role_assignment.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? each.value.role_assignment.role_definition_id_or_name : null
  role_definition_name                   = strcontains(lower(each.value.role_assignment.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? null : each.value.role_assignment.role_definition_id_or_name
  skip_service_principal_aad_check       = each.value.role_assignment.skip_service_principal_aad_check
}

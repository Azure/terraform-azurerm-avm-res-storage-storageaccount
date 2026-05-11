resource "azapi_resource" "this" {
  for_each = var.role_assignments

  name      = uuidv5("oid", "${var.scope}|${each.value.principal_id}|${local.resolved_role_definition_ids[each.key]}")
  parent_id = var.scope
  type      = "Microsoft.Authorization/roleAssignments@2022-04-01"
  body = {
    properties = {
      principalId                        = each.value.principal_id
      principalType                      = each.value.principal_type
      roleDefinitionId                   = local.resolved_role_definition_ids[each.key]
      condition                          = each.value.condition
      conditionVersion                   = each.value.condition_version
      delegatedManagedIdentityResourceId = each.value.delegated_managed_identity_resource_id
      description                        = each.value.description
    }
  }
  create_headers         = local.tracing_headers
  delete_headers         = local.tracing_headers
  read_headers           = local.tracing_headers
  response_export_values = []
  retry                  = var.retry
  update_headers         = local.tracing_headers

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }

  lifecycle {
    # principalType is server-resolved (User/ServicePrincipal/Group) when not specified; ignore to avoid drift.
    ignore_changes = [body.properties.principalType]
  }
}

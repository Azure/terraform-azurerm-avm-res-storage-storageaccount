locals {
  # Split inputs based on whether the user supplied a full resource ID or a role name.
  role_assignments_by_id = {
    for k, v in var.role_assignments : k => v
    if strcontains(lower(v.role_definition_id_or_name), local.role_definition_resource_substring)
  }
  role_assignments_by_name = {
    for k, v in var.role_assignments : k => v
    if !strcontains(lower(v.role_definition_id_or_name), local.role_definition_resource_substring)
  }
  role_definition_resource_substring = "/providers/microsoft.authorization/roledefinitions/"
}

data "azapi_client_config" "current" {}

# Look up role definition by name when the caller did not supply a full resource ID.
data "azapi_resource_list" "role_definition_lookup" {
  for_each = local.role_assignments_by_name

  parent_id = "/subscriptions/${data.azapi_client_config.current.subscription_id}"
  type      = "Microsoft.Authorization/roleDefinitions@2022-04-01"
  query_parameters = {
    "$filter" = ["roleName eq '${each.value.role_definition_id_or_name}'"]
  }
  response_export_values = ["value"]
}

locals {
  resolved_role_definition_ids = merge(
    {
      for k, v in local.role_assignments_by_id : k => v.role_definition_id_or_name
    },
    {
      for k, v in local.role_assignments_by_name : k => data.azapi_resource_list.role_definition_lookup[k].output.value[0].id
    }
  )
  tracing_headers = var.tracing_tags_header == null ? null : { "User-Agent" = var.tracing_tags_header }
}

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
  create_headers = local.tracing_headers
  delete_headers = local.tracing_headers
  read_headers   = local.tracing_headers
  retry          = var.retry
  update_headers = local.tracing_headers

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }
}

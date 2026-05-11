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

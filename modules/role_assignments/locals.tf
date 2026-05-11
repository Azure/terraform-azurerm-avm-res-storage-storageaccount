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

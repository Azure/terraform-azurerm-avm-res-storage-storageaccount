output "resource_id" {
  description = "The scope at which the role assignments were created. Provided to satisfy the AVM `resource_id` output requirement; this submodule does not own a single backing ARM resource."
  value       = var.scope
}

output "role_assignments" {
  description = "Map of role assignment resources keyed by the input map key."
  value = {
    for k, v in azapi_resource.this : k => {
      id                 = v.id
      name               = v.name
      principal_id       = v.body.properties.principalId
      role_definition_id = v.body.properties.roleDefinitionId
      scope              = var.scope
    }
  }
}

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

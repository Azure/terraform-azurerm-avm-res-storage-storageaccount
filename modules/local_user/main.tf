resource "azapi_resource" "this" {
  name      = var.name
  parent_id = var.storage_account_id
  type      = var.resource_type
  body = {
    properties = {
      homeDirectory     = var.home_directory
      hasSshKey         = var.ssh_key_enabled
      hasSshPassword    = var.ssh_password_enabled
      hasSharedKey      = false
      sshAuthorizedKeys = local.ssh_keys
      permissionScopes  = local.permission_string
    }
  }
  create_headers         = local.tracing_headers
  delete_headers         = local.tracing_headers
  ignore_null_property   = true
  read_headers           = local.tracing_headers
  response_export_values = ["properties.sid"]
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
}

# Note: the SSH password is only returned by the local user's `regeneratePassword`
# ARM action; `listKeys` returns an empty body because the Storage RP does not
# persist the password server-side. Because action results cannot flow out of a
# module via outputs without persisting them in state, retrieving the password
# is left to the consumer. Declare a managed `azapi_resource_action` block in
# your root module pointing at the local user resource (resource_id =
# `module.<...>.local_users["<key>"].id`, action = "regeneratePassword",
# response_export_values = ["sshPassword"]). The default `apply_after_create`
# behavior runs the action exactly once at create so the password is stable;
# pipe the result into a `value_wo` Key Vault secret to keep it out of state.

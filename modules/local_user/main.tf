locals {
  permission_string = var.permission_scope == null ? null : [
    for ps in var.permission_scope : {
      service      = ps.service
      resourceName = ps.resource_name
      permissions = join("", concat(
        ps.permissions.read == true ? ["r"] : [],
        ps.permissions.write == true ? ["w"] : [],
        ps.permissions.delete == true ? ["d"] : [],
        ps.permissions.list == true ? ["l"] : [],
        ps.permissions.create == true ? ["c"] : [],
      ))
    }
  ]
  ssh_keys = var.ssh_authorized_key == null ? null : [
    for k in var.ssh_authorized_key : {
      description = k.description
      key         = k.key
    }
  ]
  tracing_headers = var.tracing_tags_header == null ? null : { "User-Agent" = var.tracing_tags_header }
}

resource "azapi_resource" "this" {
  name      = var.name
  parent_id = var.storage_account_id
  type      = "Microsoft.Storage/storageAccounts/localUsers@2024-01-01"
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

# Note: the generated SSH password is exposed via the local user's `listKeys`
# ARM action. Because ephemeral resource values cannot be returned from a
# module, retrieving the SSH password is left to the consumer. Declare an
# `ephemeral "azapi_resource_action"` block in your root module pointing at
# the local user resource (resource_id = `module.<...>.local_users["<key>"].id`,
# action = "listKeys", response_export_values = ["sshPassword", "sharedKey"])
# and consume the result via `write_only` arguments or other ephemeral sinks.

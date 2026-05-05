locals {
  tracing_headers = var.tracing_tags_header == null ? null : { "User-Agent" = var.tracing_tags_header }

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
}

resource "azapi_resource" "this" {
  type      = "Microsoft.Storage/storageAccounts/localUsers@2024-01-01"
  name      = var.name
  parent_id = var.storage_account_id

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

  create_headers = local.tracing_headers
  delete_headers = local.tracing_headers
  read_headers   = local.tracing_headers
  update_headers = local.tracing_headers

  response_export_values = ["properties.sid"]

  retry = var.retry

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]

    content {
      create = timeouts.value.create
      read   = timeouts.value.read
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }
}

# Retrieve generated SSH password (if enabled) via listKeys ephemeral action.
ephemeral "azapi_resource_action" "keys" {
  count = var.ssh_password_enabled ? 1 : 0

  type                   = "Microsoft.Storage/storageAccounts/localUsers@2024-01-01"
  resource_id            = azapi_resource.this.id
  action                 = "listKeys"
  response_export_values = ["sshPassword", "sharedKey"]
}

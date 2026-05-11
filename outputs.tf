# `primary_access_key` / `secondary_access_key` are intentionally not exported.
# Terraform does not allow ephemeral outputs at the root module level, so
# consumers needing programmatic access to the keys should declare their own
# `ephemeral "azapi_resource_action"` block targeting `module.<name>.resource_id`.
# See the `examples/list_keys_ephemeral` example for the recommended pattern.

output "containers" {
  description = "Map of storage containers that are created."
  value = {
    for k, m in module.containers :
    k => {
      id   = m.resource_id
      name = m.name
    }
  }
}

output "data_lake_gen2_filesystems" {
  description = "Map of Data Lake Gen2 filesystems that are created."
  value = {
    for k, m in module.data_lake_filesystems :
    k => {
      id   = m.resource_id
      name = m.name
    }
  }
}

output "fqdn" {
  description = "Fqdns for storage services."
  value       = { for svc in local.endpoints : svc => "${azapi_resource.this.name}.${svc}.core.windows.net" }
}

output "local_users" {
  description = <<DESCRIPTION
A map of Storage Account Local Users. The map key matches `var.local_user`.

The map value contains the following attributes:
- `id` - The ID of the Storage Account Local User.
- `name` - The name of the Storage Account Local User.
- `home_directory` - The home directory of the Storage Account Local User.
- `sid` - The unique Security Identifier (SID) of the Storage Account Local User.
- `ssh_key_enabled` - Specifies whether SSH Key authentication is enabled.
- `ssh_password_enabled` - Specifies whether SSH password authentication is enabled.

NOTE: The local user `password` attribute is no longer exported. The Storage RP
only returns the password from the `regeneratePassword` ARM action (the
`listKeys` action returns an empty body because the password is not persisted
server-side). Declare a managed `azapi_resource_action` resource with
`action = "regeneratePassword"` and `response_export_values = ["sshPassword"]`
in the consuming root module; the default `apply_after_create` behavior calls
the action exactly once at create so the password is stable. Pipe the result
through `value_wo` on `azurerm_key_vault_secret` to keep it out of state.
DESCRIPTION
  sensitive   = true
  value = {
    for k, m in module.local_users :
    k => {
      id                   = m.resource_id
      name                 = m.name
      home_directory       = m.home_directory
      sid                  = m.sid
      ssh_key_enabled      = m.ssh_key_enabled
      ssh_password_enabled = m.ssh_password_enabled
    }
  }
}

output "name" {
  description = "The name of the storage account."
  value       = azapi_resource.this.name
}

output "private_endpoints" {
  description = <<DESCRIPTION
A map of private endpoints created by the module. The map key matches `var.private_endpoints`.

Each value is an object with:
- `id` - The resource ID of the private endpoint.
- `name` - The name of the private endpoint.
- `private_dns_zone_group_id` - The resource ID of the managed private DNS zone group, or `null` if not managed by this module.
- `role_assignments` - Map of role assignments created at the private endpoint scope.
DESCRIPTION
  value = {
    for k, m in module.private_endpoints :
    k => {
      id                        = m.resource_id
      name                      = m.name
      private_dns_zone_group_id = m.private_dns_zone_group_id
      role_assignments          = m.role_assignments
    }
  }
}

output "queues" {
  description = "Map of storage queues that are created."
  value = {
    for k, m in module.queues :
    k => {
      id   = m.resource_id
      name = m.name
    }
  }
}

output "resource" {
  description = "The full Storage Account azapi_resource."
  sensitive   = true
  value       = azapi_resource.this
}

output "resource_id" {
  description = "The ID of the Storage Account."
  value       = azapi_resource.this.id
}

output "shares" {
  description = "Map of storage file shares that are created."
  value = {
    for k, m in module.shares :
    k => {
      id   = m.resource_id
      name = m.name
    }
  }
}

output "tables" {
  description = "Map of storage tables that are created."
  value = {
    for k, m in module.tables :
    k => {
      id                   = m.resource_id
      name                 = m.name
      storage_account_name = azapi_resource.this.name
    }
  }
}

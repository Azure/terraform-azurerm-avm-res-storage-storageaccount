output "containers" {
  description = "Map of storage containers that are created."
  value = {
    for k, m in module.containers :
    k => {
      id   = m.id
      name = m.name
    }
  }
}

output "data_lake_gen2_filesystems" {
  description = "Map of Data Lake Gen2 filesystems that are created."
  value = {
    for k, m in module.data_lake_filesystems :
    k => {
      id   = m.id
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

NOTE: The local user `password` attribute is no longer exported as a non-sensitive
output. Use the ephemeral `azapi_resource_action.keys` inside the local_user
submodule (or a `listKeys` action of your own) to retrieve credentials at apply
time without persisting them in state.
DESCRIPTION
  sensitive   = true
  value = {
    for k, m in module.local_users :
    k => {
      id                   = m.id
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

# v1.0.0 BREAKING CHANGE: `primary_access_key` / `secondary_access_key`
# outputs are removed because the access keys are now retrieved via the
# ephemeral `azapi_resource_action.storage_account_keys` resource inside the
# module and Terraform does not permit ephemeral outputs at the root module
# level. Consumers needing programmatic access to the keys should instantiate
# their own `ephemeral "azapi_resource_action"` block targeting the storage
# account `id` exported from this module (`module.<name>.resource_id`).

output "private_endpoints" {
  description = "A map of private endpoints. The map key matches `var.private_endpoints`. Each value is the full azapi_resource exposing the private endpoint."
  value = {
    for k, m in module.private_endpoints :
    k => m.resource
  }
}

output "queues" {
  description = "Map of storage queues that are created."
  value = {
    for k, m in module.queues :
    k => {
      id   = m.id
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
      id   = m.id
      name = m.name
    }
  }
}

output "tables" {
  description = "Map of storage tables that are created."
  value = {
    for k, m in module.tables :
    k => {
      id                   = m.id
      name                 = m.name
      storage_account_name = azapi_resource.this.name
    }
  }
}

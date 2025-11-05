output "containers" {
  description = "Map of storage containers that are created."
  value = {
    for name, container in azapi_resource.containers :
    name => {
      id   = container.id
      name = container.name
    }
  }
}

output "data_lake_gen2_filesystems" {
  description = "Map of Data Lake Gen2 filesystems that are created."
  value = {
    for name, filesystem in azurerm_storage_data_lake_gen2_filesystem.this :
    name => {
      id   = filesystem.id
      name = filesystem.name
    }
  }
}

output "fqdn" {
  description = "Fqdns for storage services."
  value       = { for svc in local.endpoints : svc => "${azurerm_storage_account.this.name}.${svc}.core.windows.net" }
}

output "local_users" {
  description = <<DESCRIPTION
A map of Storage Account Local Users. The map key is the supplied input to var.local_user. Contains sensitive information including passwords when ssh_password_enabled is true.

The map value contains the following attributes:
- `id` - The ID of the Storage Account Local User.
- `name` - The name of the Storage Account Local User.
- `home_directory` - The home directory of the Storage Account Local User.
- `password` - The password of the Storage Account Local User (sensitive).
- `sid` - The unique Security Identifier (SID) of the Storage Account Local User.
- `ssh_key_enabled` - Specifies whether SSH Key authentication is enabled.
- `ssh_password_enabled` - Specifies whether SSH password authentication is enabled.
DESCRIPTION
  sensitive   = true
  value = {
    for key, user in azurerm_storage_account_local_user.this :
    key => {
      id                   = user.id
      name                 = user.name
      home_directory       = user.home_directory
      password             = user.password
      sid                  = user.sid
      ssh_key_enabled      = user.ssh_key_enabled
      ssh_password_enabled = user.ssh_password_enabled
    }
  }
}

output "name" {
  description = "The name of the storage account"
  value       = azurerm_storage_account.this.name
}

output "private_endpoints" {
  description = "A map of private endpoints. The map key is the supplied input to var.private_endpoints. The map value is the entire azurerm_private_endpoint resource."
  value       = var.private_endpoints_manage_dns_zone_group ? azurerm_private_endpoint.this : azurerm_private_endpoint.this_unmanaged_dns_zone_groups
}

output "queues" {
  description = "Map of storage queues that are created."
  value = {
    for name, queue in azapi_resource.queue :
    name => {
      id   = queue.id
      name = queue.name
    }
  }
}

output "resource" {
  description = "This is the full resource output for the Storage Account resource."
  sensitive   = true
  value       = azurerm_storage_account.this
}

output "resource_id" {
  description = "The ID of the Storage Account."
  value       = azurerm_storage_account.this.id
}

output "shares" {
  description = "Map of storage storage shares that are created."
  value = {
    for name, share in azapi_resource.share : name => {
      id   = share.id
      name = share.name
    }
  }
}

output "tables" {
  description = "Map of storage tables that are created."
  value = {
    for name, table in azapi_resource.table : name => {
      id                   = table.id
      name                 = table.name
      storage_account_name = azurerm_storage_account.this.name
    }
  }
}

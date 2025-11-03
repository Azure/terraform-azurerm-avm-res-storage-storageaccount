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

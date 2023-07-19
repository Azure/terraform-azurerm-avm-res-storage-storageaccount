output "fqdn" {
  description = "Fqdns for storage services."
  value       = { for svc in local.endpoints : svc => "${azurerm_storage_account.this.name}.${svc}.core.windows.net" }
}

output "private_endpoint_id" {
  description = "Id of created private endpoint"
  value       = { for name, pe in azurerm_private_endpoint.this : name => pe.id }
}

output "private_endpoint_private_ip" {
  description = "Map of private IP of created private endpoints"
  value       = { for name, pe in azurerm_private_endpoint.this : name => pe.private_service_connection[0].private_ip_address }
}

output "storage_account_id" {
  description = "The ID of the Storage Account."
  value       = azurerm_storage_account.this.id
}

output "storage_account_name" {
  description = "The name of the storage account"
  value       = azurerm_storage_account.this.name
}

output "storage_account_primary_access_key" {
  description = "The primary access key for the storage account."
  sensitive   = true
  value       = azurerm_storage_account.this.primary_access_key
}

output "storage_account_primary_blob_connection_string" {
  description = "The connection string associated with the primary blob location."
  sensitive   = true
  value       = azurerm_storage_account.this.primary_blob_connection_string
}

output "storage_account_primary_blob_endpoint" {
  description = "The endpoint URL for blob storage in the primary location."
  value       = azurerm_storage_account.this.primary_blob_endpoint
}

output "storage_account_primary_blob_host" {
  description = "The hostname with port if applicable for blob storage in the primary location."
  value       = azurerm_storage_account.this.primary_blob_host
}

output "storage_account_primary_connection_string" {
  description = "The connection string associated with the primary location."
  sensitive   = true
  value       = azurerm_storage_account.this.primary_connection_string
}

output "storage_account_primary_location" {
  description = "The primary location of the storage account."
  value       = azurerm_storage_account.this.primary_location
}

output "storage_account_primary_queue_endpoint" {
  description = "The endpoint URL for queue storage in the primary location."
  value       = azurerm_storage_account.this.primary_queue_endpoint
}

output "storage_account_primary_queue_host" {
  description = "The hostname with port if applicable for queue storage in the primary location."
  value       = azurerm_storage_account.this.primary_queue_host
}

output "storage_account_primary_table_endpoint" {
  description = "The endpoint URL for table storage in the primary location."
  value       = azurerm_storage_account.this.primary_table_endpoint
}

output "storage_account_primary_table_host" {
  description = "The hostname with port if applicable for table storage in the primary location."
  value       = azurerm_storage_account.this.primary_table_host
}

output "storage_account_secondary_access_key" {
  description = "The secondary access key for the storage account."
  sensitive   = true
  value       = azurerm_storage_account.this.secondary_access_key
}

output "storage_account_secondary_blob_connection_string" {
  description = "The connection string associated with the secondary blob location."
  sensitive   = true
  value       = azurerm_storage_account.this.secondary_blob_connection_string
}

output "storage_account_secondary_blob_endpoint" {
  description = "The endpoint URL for blob storage in the secondary location."
  value       = azurerm_storage_account.this.secondary_blob_endpoint
}

output "storage_account_secondary_blob_host" {
  description = "The hostname with port if applicable for blob storage in the secondary location."
  value       = azurerm_storage_account.this.secondary_blob_host
}

output "storage_account_secondary_connection_string" {
  description = "The connection string associated with the secondary location."
  sensitive   = true
  value       = azurerm_storage_account.this.secondary_connection_string
}

output "storage_account_secondary_location" {
  description = "The secondary location of the storage account."
  value       = azurerm_storage_account.this.secondary_location
}

output "storage_account_secondary_queue_endpoint" {
  description = "The endpoint URL for queue storage in the secondary location."
  value       = azurerm_storage_account.this.secondary_queue_endpoint
}

output "storage_account_secondary_queue_host" {
  description = "The hostname with port if applicable for queue storage in the secondary location."
  value       = azurerm_storage_account.this.secondary_queue_host
}

output "storage_account_secondary_table_endpoint" {
  description = "The endpoint URL for table storage in the secondary location."
  value       = azurerm_storage_account.this.secondary_table_endpoint
}

output "storage_account_secondary_table_host" {
  description = "The hostname with port if applicable for table storage in the secondary location."
  value       = azurerm_storage_account.this.secondary_table_host
}

output "storage_container" {
  description = "Map of storage containers that created."
  value = {
    for name, container in azurerm_storage_container.this :
    name => {
      id                    = container.id
      name                  = container.name
      storage_account_name  = container.storage_account_name
      container_access_type = container.container_access_type
      metadata              = container.metadata
    }
  }
}

output "storage_queue" {
  description = "Map of storage queues that created."
  value = {
    for name, queue in azurerm_storage_queue.this :
    name => {
      id                   = queue.id
      name                 = queue.name
      storage_account_name = queue.storage_account_name
      metadata             = queue.metadata
    }
  }
}

output "storage_table" {
  description = "Map of storage tables that created."
  value = {
    for name, table in azurerm_storage_table.this : name => {
      id                   = table.id
      name                 = table.name
      storage_account_name = table.storage_account_name
    }
  }
}

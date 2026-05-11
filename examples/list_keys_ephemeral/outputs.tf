output "key_vault_secret_id" {
  description = "Resource ID of the Key Vault secret holding the storage account primary access key."
  value       = azurerm_key_vault_secret.primary_key.id
}

output "storage_account_id" {
  description = "Resource ID of the storage account."
  value       = module.this.resource_id
}

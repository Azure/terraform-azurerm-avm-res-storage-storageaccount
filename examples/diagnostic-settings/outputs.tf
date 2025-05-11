output "containers" {
  description = "value of containers"
  value       = module.this.containers
}

output "eventhub_authorization_rule_primary_key" {
  description = "Primary key for the event hub authorisation rule"
  sensitive   = true
  value       = azurerm_eventhub_authorization_rule.this.primary_key
}

output "queue" {
  description = "value of queues"
  value       = module.this.queues
}

output "resource" {
  description = "value of storage_account"
  sensitive   = true
  value       = module.this.resource
}

output "shares" {
  description = "value of shares"
  value       = module.this.shares
}

output "tables" {
  description = "value of tables"
  value       = module.this.tables
}

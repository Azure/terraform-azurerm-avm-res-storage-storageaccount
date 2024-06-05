output "shares" {
  description = "value of shares"
  value       = module.this.shares
}

output "queue" {
  description = "value of queues"
  value       = module.this.queues
}
output "tables" {
  description = "value of tables"
  value       = module.this.tables
}
output "containers" {
  description = "value of containers"
  value       = module.this.containers
}

output "storage_account" {
  description = "value of storage_account"
  value       = module.this.storage_account
  sensitive   = true
}

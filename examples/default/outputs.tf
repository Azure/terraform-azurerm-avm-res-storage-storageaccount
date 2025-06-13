output "containers" {
  description = "value of containers"
  value       = module.this.containers
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

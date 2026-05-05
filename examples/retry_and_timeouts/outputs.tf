output "containers" {
  description = "value of containers"
  value       = module.this.containers
}

output "name" {
  description = "value of storage_account name"
  value       = module.this.name
}

output "resource_id" {
  description = "value of storage_account resource_id"
  value       = module.this.resource_id
}

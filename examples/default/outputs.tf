output "containers" {
  description = "value of containers"
  value       = module.this.containers
}

output "resource" {
  description = "value of storage_account"
  sensitive   = true
  value       = module.this.resource
}

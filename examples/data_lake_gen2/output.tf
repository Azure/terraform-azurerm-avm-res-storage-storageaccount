output "resource" {
  description = "value of storage_account"
  value       = module.this.resource
  sensitive   = true
}

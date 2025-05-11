output "resource" {
  description = "value of storage_account"
  sensitive   = true
  value       = module.this.resource
}

output "local_users" {
  description = "A map of Storage Account Local Users created by the module."
  sensitive   = true
  value       = module.this.local_users
}

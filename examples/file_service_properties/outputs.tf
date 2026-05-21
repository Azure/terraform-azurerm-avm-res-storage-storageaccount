output "resource" {
  description = "The storage account resource."
  sensitive   = true
  value       = module.this.resource
}

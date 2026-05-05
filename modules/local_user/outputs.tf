output "id" {
  description = "The resource ID of the local user."
  value       = azapi_resource.this.id
}

output "name" {
  description = "The name of the local user."
  value       = azapi_resource.this.name
}

output "home_directory" {
  description = "The home directory of the local user."
  value       = var.home_directory
}

output "sid" {
  description = "The Security Identifier (SID) assigned to the local user."
  value       = azapi_resource.this.output.properties.sid
}

output "ssh_key_enabled" {
  description = "Whether SSH key authentication is enabled."
  value       = var.ssh_key_enabled
}

output "ssh_password_enabled" {
  description = "Whether SSH password authentication is enabled."
  value       = var.ssh_password_enabled
}

output "resource" {
  description = "The full local user azapi_resource."
  value       = azapi_resource.this
}

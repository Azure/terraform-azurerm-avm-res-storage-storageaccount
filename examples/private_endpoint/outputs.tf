output "private_endpoint_ip" {
  value = module.this.private_endpoint_private_ip
}

output "service_fqdn" {
  value = module.this.fqdn
}
/*
output "service_fqdn2" {
  value = module.another_container.fqdn
}
*/
output "storage_account_primary_access_key" {
  sensitive = true
  value     = module.this.storage_account_primary_access_key
}

output "storage_account_primary_connection_string" {
  sensitive = true
  value     = module.this.storage_account_primary_connection_string
}
/*
output "storage_account_primary_connection_string2" {
  sensitive = true
  value     = module.another_container.storage_account_primary_connection_string
}
*/

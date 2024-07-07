output "container_name" {
  description = "The name of the container"
  value       = azapi_resource.containers.name

}
output "id_storage_container" {
  description = "value of the storage container id"
  value       = azapi_resource.containers.id
}

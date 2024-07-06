output "queue_name" {
  description = "The name of the queue"
  value       = azapi_resource.queue.name

}
output "id_storage_queue" {
  description = "value of the storage queue id"
  value       = azapi_resource.queue.id
}

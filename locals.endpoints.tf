locals {
  blob_endpoint  = length(var.containers) == 0 ? [] : ["blob"]
  endpoints      = toset(concat(local.blob_endpoint, local.queue_endpoint, local.table_endpoint))
  queue_endpoint = length(var.queues) == 0 ? [] : ["queue"]
  table_endpoint = length(var.tables) == 0 ? [] : ["table"]
}

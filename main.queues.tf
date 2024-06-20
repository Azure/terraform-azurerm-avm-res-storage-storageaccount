module "storage_queue" {
  source   = "./modules/storage_queue"
  for_each = var.queues



}

module "queue" {
  source   = "./modules/queue"
  for_each = var.queues
  name     = each.value.name
}

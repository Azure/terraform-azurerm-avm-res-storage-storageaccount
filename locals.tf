locals {
  blob_endpoint  = length(var.containers) == 0 ? [] : ["blob"]
  queue_endpoint = length(var.queues) == 0 ? [] : ["queue"]
  table_endpoint = length(var.tables) == 0 ? [] : ["table"]

  endpoints = toset(concat(local.blob_endpoint, local.queue_endpoint, local.table_endpoint))

  has_management_policy = length(var.storage_management_policy_rule) > 0

  # Resource group name extracted from the parent_id input. Used for child
  # resources (such as private endpoints) that need a discrete
  # resource_group_name and historical state migrations.
  resource_group_name = regex("^/subscriptions/[^/]+/resourceGroups/([^/]+)$", var.parent_id)[0]
}

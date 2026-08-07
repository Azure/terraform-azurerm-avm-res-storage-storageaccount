terraform {
  required_providers {
    azapi = {
      source = "Azure/azapi"
    }
  }
}

locals {
  storage_account_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test/providers/Microsoft.Storage/storageAccounts/ststatemigration"
}

resource "azapi_resource" "containers" {
  for_each = { container = "container" }

  name      = each.value
  parent_id = "${local.storage_account_id}/blobServices/default"
  type      = "Microsoft.Storage/storageAccounts/blobServices/containers@2025-06-01"
  body      = {}
}

resource "azapi_resource" "queue" {
  for_each = { queue = "queue" }

  name      = each.value
  parent_id = "${local.storage_account_id}/queueServices/default"
  type      = "Microsoft.Storage/storageAccounts/queueServices/queues@2025-06-01"
  body      = {}
}

resource "azapi_resource" "share" {
  for_each = { share = "share" }

  name      = each.value
  parent_id = "${local.storage_account_id}/fileServices/default"
  type      = "Microsoft.Storage/storageAccounts/fileServices/shares@2025-06-01"
  body      = {}
}

resource "azapi_resource" "table" {
  for_each = { table = "table" }

  name      = each.value
  parent_id = "${local.storage_account_id}/tableServices/default"
  type      = "Microsoft.Storage/storageAccounts/tableServices/tables@2025-06-01"
  body      = {}
}

output "resource_ids" {
  value = {
    container = azapi_resource.containers["container"].id
    queue     = azapi_resource.queue["queue"].id
    share     = azapi_resource.share["share"].id
    table     = azapi_resource.table["table"].id
  }
}

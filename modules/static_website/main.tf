locals {
  tracing_headers = var.tracing_tags_header == null ? null : { "User-Agent" = var.tracing_tags_header }
}

# Static website is enabled by patching the blobServices/default sub-resource.
# We use azapi_update_resource so we don't try to manage the entire blobServices
# object — only the staticWebsite property.
resource "azapi_update_resource" "this" {
  type        = "Microsoft.Storage/storageAccounts/blobServices@2024-01-01"
  resource_id = "${var.storage_account_id}/blobServices/default"

  body = {
    properties = {
      staticWebsite = {
        enabled              = true
        indexDocument        = var.index_document
        errorDocument404Path = var.error_404_document
      }
    }
  }

  create_headers = local.tracing_headers
  read_headers   = local.tracing_headers
  update_headers = local.tracing_headers

  retry = var.retry

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]

    content {
      create = timeouts.value.create
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }
}

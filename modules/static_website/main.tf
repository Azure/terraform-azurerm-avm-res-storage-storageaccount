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

  # `azapi_update_resource` does not expose per-action header attributes;
  # tracing headers are emitted on the parent storage account resource. The
  # `local.tracing_headers` value remains computed (above) so it is preserved
  # for future header support without a config-shape change.

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

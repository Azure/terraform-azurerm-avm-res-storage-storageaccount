locals {
  tracing_headers = var.tracing_tags_header == null ? null : { "User-Agent" = var.tracing_tags_header }
}

# A Data Lake Gen2 filesystem on an HNS-enabled storage account is represented
# in ARM as a blob container. We manage the control-plane-only properties here
# (name, default encryption scope, metadata).
#
# NOTE: Setting `owner`, `group` and POSIX `ace` entries is a pure data-plane
# operation against the DFS endpoint and is not exposed by ARM. Those features
# are not provided by this submodule. Manage them externally if required.
resource "azapi_resource" "this" {
  type      = "Microsoft.Storage/storageAccounts/blobServices/containers@2024-01-01"
  name      = var.name
  parent_id = "${var.storage_account_id}/blobServices/default"

  body = {
    properties = {
      defaultEncryptionScope = var.default_encryption_scope
      metadata               = var.metadata
    }
  }

  create_headers = local.tracing_headers
  delete_headers = local.tracing_headers
  read_headers   = local.tracing_headers
  update_headers = local.tracing_headers

  retry = var.retry

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]

    content {
      create = timeouts.value.create
      read   = timeouts.value.read
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }
}

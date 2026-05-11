# A Data Lake Gen2 filesystem on an HNS-enabled storage account is represented
# in ARM as a blob container. We manage the control-plane-only properties here
# (name, default encryption scope, metadata).
#
# NOTE: Setting `owner`, `group` and POSIX `ace` entries is a pure data-plane
# operation against the DFS endpoint and is not exposed by ARM. Those features
# are not provided by this submodule. Manage them externally if required.
resource "azapi_resource" "this" {
  name      = var.name
  parent_id = "${var.storage_account_id}/blobServices/default"
  type      = var.resource_type
  body = {
    properties = {
      defaultEncryptionScope = var.default_encryption_scope
      metadata               = var.metadata
    }
  }
  create_headers         = local.tracing_headers
  delete_headers         = local.tracing_headers
  read_headers           = local.tracing_headers
  response_export_values = []
  retry                  = var.retry
  update_headers         = local.tracing_headers

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }

  lifecycle {
    # defaultEncryptionScope is set at container creation time and cannot be
    # mutated afterwards (Azure rejects PUT updates without the special
    # x-ms-default-encryption-scope/x-ms-deny-encryption-scope-override
    # headers). Ignoring drift avoids spurious updates and apply failures.
    ignore_changes = [body.properties.defaultEncryptionScope]
  }
}

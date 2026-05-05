locals {
  tracing_headers = var.tracing_tags_header == null ? null : { "User-Agent" = var.tracing_tags_header }

  body_properties = {
    metadata                       = var.metadata == null ? {} : var.metadata
    publicAccess                   = var.public_access
    defaultEncryptionScope         = var.default_encryption_scope
    denyEncryptionScopeOverride    = var.deny_encryption_scope_override
    enableNfsV3AllSquash           = var.enable_nfs_v3_all_squash
    enableNfsV3RootSquash          = var.enable_nfs_v3_root_squash
    immutableStorageWithVersioning = var.immutable_storage_with_versioning
  }
}

resource "azapi_resource" "this" {
  type      = "Microsoft.Storage/storageAccounts/blobServices/containers@2024-01-01"
  name      = var.name
  parent_id = "${var.storage_account_id}/blobServices/default"

  body = {
    properties = local.body_properties
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

module "role_assignments" {
  source = "../role_assignments"

  scope               = azapi_resource.this.id
  role_assignments    = var.role_assignments
  retry               = var.retry
  timeouts            = var.timeouts
  tracing_tags_header = var.tracing_tags_header
}

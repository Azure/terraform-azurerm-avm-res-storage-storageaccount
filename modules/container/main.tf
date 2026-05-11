locals {
  body_properties = {
    metadata                       = var.metadata == null ? {} : var.metadata
    publicAccess                   = var.public_access
    defaultEncryptionScope         = coalesce(var.default_encryption_scope, "$account-encryption-key")
    denyEncryptionScopeOverride    = var.deny_encryption_scope_override == null ? false : var.deny_encryption_scope_override
    enableNfsV3AllSquash           = var.enable_nfs_v3_all_squash
    enableNfsV3RootSquash          = var.enable_nfs_v3_root_squash
    immutableStorageWithVersioning = var.immutable_storage_with_versioning
  }
  tracing_headers = var.tracing_tags_header == null ? null : { "User-Agent" = var.tracing_tags_header }
}

resource "azapi_resource" "this" {
  name      = var.name
  parent_id = "${var.storage_account_id}/blobServices/default"
  type      = "Microsoft.Storage/storageAccounts/blobServices/containers@2024-01-01"
  body = {
    properties = local.body_properties
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
}

module "role_assignments" {
  # tflint-ignore: required_module_source_tffr1 # relative source is intentional: this is an in-module composition of the role_assignments submodule
  source = "../role_assignments"

  scope               = azapi_resource.this.id
  retry               = var.retry
  role_assignments    = var.role_assignments
  timeouts            = var.timeouts
  tracing_tags_header = var.tracing_tags_header
}

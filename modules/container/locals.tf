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

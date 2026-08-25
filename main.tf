resource "azapi_resource" "this" {
  location  = var.location
  name      = var.name
  parent_id = var.parent_id
  type      = var.resource_types.storage_account
  body = {
    kind             = var.account_kind
    extendedLocation = local.extended_location
    sku = {
      name = local.sku_name
    }
    properties = {
      accessTier                            = var.account_kind == "BlockBlobStorage" && local.effective_account_tier == "Premium" ? null : var.access_tier
      allowBlobPublicAccess                 = var.allow_nested_items_to_be_public
      allowCrossTenantReplication           = var.cross_tenant_replication_enabled
      allowedCopyScope                      = var.allowed_copy_scope
      allowSharedKeyAccess                  = var.shared_access_key_enabled
      azureFilesIdentityBasedAuthentication = local.azure_files_identity_based_authentication
      customDomain                          = local.custom_domain
      defaultToOAuthAuthentication          = var.default_to_oauth_authentication
      encryption                            = local.encryption
      immutableStorageWithVersioning        = local.immutable_storage_with_versioning
      isHnsEnabled                          = var.is_hns_enabled
      isLocalUserEnabled                    = var.local_user_enabled
      isNfsV3Enabled                        = var.nfsv3_enabled
      isSftpEnabled                         = var.sftp_enabled
      largeFileSharesState                  = local.large_file_shares_state
      minimumTlsVersion                     = var.min_tls_version
      networkAcls                           = local.network_acls
      publicNetworkAccess                   = local.public_network_access_setting
      routingPreference                     = local.routing_preference
      sasPolicy                             = local.sas_policy
      supportsHttpsTrafficOnly              = var.https_traffic_only_enabled
    }
  }
  create_headers       = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers       = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  ignore_null_property = true
  read_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  response_export_values = [
    "identity",
    "properties.primaryEndpoints",
    "properties.secondaryEndpoints",
    "properties.primaryLocation",
    "properties.secondaryLocation",
  ]
  retry          = var.retry
  tags           = var.tags
  update_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null

  dynamic "identity" {
    for_each = local.managed_identity_type == null ? [] : [local.managed_identity_type]

    content {
      type         = identity.value
      identity_ids = var.managed_identities.user_assigned_resource_ids
    }
  }

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
    # Smart access tier is only supported for StorageV2 accounts with
    # ZRS, GZRS or RA-GZRS redundancy. Validate the account configuration
    # early to provide a clear error message before calling the Azure API.
    precondition {
      condition = (
        var.access_tier == "Smart"
        ? (
          var.account_kind == "StorageV2" &&
          contains(["Standard_ZRS", "Standard_GZRS", "Standard_RAGZRS"], local.sku_name)
        )
        : true
      )

      error_message = "Smart access tier requires account_kind = StorageV2 and SKU Standard_ZRS, Standard_GZRS or Standard_RAGZRS."
    }

    # Smart access tier requires Storage API version 2025-08-01 or later.
    # The api-version date is captured from the `@<date>` suffix. Any trailing
    # qualifier is ignored for this minimum-version comparison; AzAPI schema
    # validation still determines whether the exact API version is supported.
    # The date is turned into an integer (YYYYMMDD) for the comparison, because
    # Terraform's `>=` operator only works on numbers, not on strings.
    precondition {
      condition = var.access_tier != "Smart" || try(
        tonumber(replace(regex("@(\\d{4}-\\d{2}-\\d{2})", var.resource_types.storage_account)[0], "-", "")) >= 20250801,
        false
      )

      error_message = "Smart access tier requires resource_types.storage_account to use Microsoft.Storage/storageAccounts@2025-08-01 or later."
    }
    # CMK fields are owned by azapi_update_resource.customer_managed_key.
    ignore_changes = [
      body.properties.encryption.keySource,
      body.properties.encryption.identity,
      body.properties.encryption.keyvaultproperties,
    ]
  }
}

# Customer-managed key encryption is applied as a second step. Azure rejects a
# single PUT that both associates a user-assigned identity with the storage
# account and references that identity in `properties.encryption.identity`, so
# the account is created with default Microsoft.Storage encryption and then
# patched to Microsoft.Keyvault here.
resource "azapi_update_resource" "customer_managed_key" {
  count = local.customer_managed_key_enabled ? 1 : 0

  resource_id = azapi_resource.this.id
  type        = var.resource_types.storage_account
  body = {
    properties = {
      encryption = local.encryption_cmk
    }
  }
  read_headers   = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  retry          = var.retry
  update_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]

    content {
      create = timeouts.value.create
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }
}

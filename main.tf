locals {
  # Azure Files identity-based auth mapping
  azure_files_identity_based_authentication = var.azure_files_authentication == null ? null : {
    directoryServiceOptions = var.azure_files_authentication.directory_type
    defaultSharePermission  = var.azure_files_authentication.default_share_level_permission
    activeDirectoryProperties = var.azure_files_authentication.active_directory == null ? null : {
      domainGuid        = var.azure_files_authentication.active_directory.domain_guid
      domainName        = var.azure_files_authentication.active_directory.domain_name
      domainSid         = var.azure_files_authentication.active_directory.domain_sid
      forestName        = var.azure_files_authentication.active_directory.forest_name
      netBiosDomainName = var.azure_files_authentication.active_directory.netbios_domain_name
      azureStorageSid   = var.azure_files_authentication.active_directory.storage_sid
    }
  }
  # Custom domain
  custom_domain = var.custom_domain == null ? null : {
    name             = var.custom_domain.name
    useSubDomainName = var.custom_domain.use_subdomain
  }
  # Whether a customer-managed key is configured.
  customer_managed_key_enabled = var.customer_managed_key != null
  # Initial encryption block sent on storage account create. CMK fields
  # (keySource = Microsoft.Keyvault, identity, keyvaultproperties) cannot be
  # accepted by ARM in the same PUT that first associates the user-assigned
  # identity with the account, so they are applied via azapi_update_resource
  # in a second step (see azapi_update_resource.customer_managed_key).
  encryption = {
    keySource                       = "Microsoft.Storage"
    requireInfrastructureEncryption = var.infrastructure_encryption_enabled ? true : null
    services                        = { for k, v in local.encryption_services : k => v if v != null }
  }
  # Full encryption body applied via azapi_update_resource once the storage
  # account exists and its identity is in place.
  encryption_cmk = local.customer_managed_key_enabled ? {
    keySource                       = "Microsoft.Keyvault"
    requireInfrastructureEncryption = var.infrastructure_encryption_enabled ? true : null
    services                        = { for k, v in local.encryption_services : k => v if v != null }
    keyvaultproperties              = local.encryption_keyvault
    identity                        = local.encryption_identity
  } : null
  encryption_identity = local.customer_managed_key_enabled && try(var.customer_managed_key.user_assigned_identity, null) != null ? {
    userAssignedIdentity = var.customer_managed_key.user_assigned_identity.resource_id
  } : null
  encryption_keyvault = local.customer_managed_key_enabled ? {
    keyname     = var.customer_managed_key.key_name
    keyvaulturi = data.azapi_resource.customer_managed_key_vault[0].output.properties.vaultUri
    keyversion  = var.customer_managed_key.key_version
  } : null
  encryption_services = {
    queue = var.queue_encryption_key_type == null ? null : {
      keyType = var.queue_encryption_key_type
      enabled = true
    }
    table = var.table_encryption_key_type == null ? null : {
      keyType = var.table_encryption_key_type
      enabled = true
    }
  }
  extended_location = var.edge_zone == null ? null : {
    name = var.edge_zone
    type = "EdgeZone"
  }
  # Account-level immutability policy (immutableStorageWithVersioning)
  immutable_storage_with_versioning = var.immutability_policy == null ? null : {
    enabled = true
    immutabilityPolicy = {
      allowProtectedAppendWrites            = var.immutability_policy.allow_protected_append_writes
      immutabilityPeriodSinceCreationInDays = var.immutability_policy.period_since_creation_in_days
      state                                 = var.immutability_policy.state
    }
  }
  large_file_shares_state = var.large_file_share_enabled == null ? null : (var.large_file_share_enabled ? "Enabled" : "Disabled")
  # Identity composition. Returns null when no identity is configured so the
  # body omits the field entirely.
  managed_identity_type = (
    var.managed_identities.system_assigned && length(var.managed_identities.user_assigned_resource_ids) > 0 ? "SystemAssigned, UserAssigned" :
    var.managed_identities.system_assigned ? "SystemAssigned" :
    length(var.managed_identities.user_assigned_resource_ids) > 0 ? "UserAssigned" :
    null
  )
  # Network ACLs mapping
  network_acls = var.network_rules == null ? null : {
    bypass        = var.network_rules.bypass == null ? null : (length(var.network_rules.bypass) == 0 ? "None" : join(", ", tolist(var.network_rules.bypass)))
    defaultAction = var.network_rules.default_action
    ipRules       = var.network_rules.ip_rules == null ? null : [for ip in var.network_rules.ip_rules : { value = ip, action = "Allow" }]
    virtualNetworkRules = var.network_rules.virtual_network_subnet_ids == null ? null : [
      for id in var.network_rules.virtual_network_subnet_ids : { id = id, action = "Allow" }
    ]
    resourceAccessRules = var.network_rules.private_link_access == null ? null : [
      for r in var.network_rules.private_link_access : {
        resourceId = r.endpoint_resource_id
        tenantId   = r.endpoint_tenant_id
      }
    ]
  }
  public_network_access_setting = var.public_network_access_enabled == null ? null : (var.public_network_access_enabled ? "Enabled" : "Disabled")
  # Routing preference
  routing_preference = var.routing == null ? null : {
    routingChoice             = var.routing.choice
    publishInternetEndpoints  = var.routing.publish_internet_endpoints
    publishMicrosoftEndpoints = var.routing.publish_microsoft_endpoints
  }
  # SAS policy
  sas_policy = var.sas_policy == null ? null : {
    sasExpirationPeriod = var.sas_policy.expiration_period
    expirationAction    = var.sas_policy.expiration_action
  }
  # SKU name combines tier + replication, with optional V2 suffix when the
  # provisioned billing model V2 is requested (StandardV2_*, PremiumV2_*).
  # When `var.account_sku_name` is supplied it wins over the derived value.
  sku_name = coalesce(var.account_sku_name, var.provisioned_billing_model_version == "V2" ? "${var.account_tier}V2_${var.account_replication_type}" : "${var.account_tier}_${var.account_replication_type}")
}

# Customer-managed key vault data source. We need the vault URI for the
# encryption block; the user supplies a vault resource ID.
data "azapi_resource" "customer_managed_key_vault" {
  count = local.customer_managed_key_enabled ? 1 : 0

  resource_id            = var.customer_managed_key.key_vault_resource_id
  type                   = "Microsoft.KeyVault/vaults@2023-07-01"
  response_export_values = ["properties.vaultUri"]
}

resource "azapi_resource" "this" {
  location  = var.location
  name      = var.name
  parent_id = var.parent_id
  type      = "Microsoft.Storage/storageAccounts@2024-01-01"
  body = {
    kind             = var.account_kind
    extendedLocation = local.extended_location
    sku = {
      name = local.sku_name
    }
    properties = {
      accessTier                            = var.account_kind == "BlockBlobStorage" && var.account_tier == "Premium" ? null : var.access_tier
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
  type        = "Microsoft.Storage/storageAccounts@2024-01-01"
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

# State migration: the storage account previously was azurerm_storage_account.this
# but maps to the same ARM resource ID, so a moved block lets state transition
# without recreation.
moved {
  from = azurerm_storage_account.this
  to   = azapi_resource.this
}

# v1.0.0 BREAKING CHANGE: Storage account access keys are no longer exposed by
# this module. Consumers needing programmatic access can declare their own
# ephemeral listKeys action against the storage account ID exported by this
# module:
#
#   ephemeral "azapi_resource_action" "keys" {
#     type        = "Microsoft.Storage/storageAccounts@2024-01-01"
#     resource_id = module.storage_account.resource_id
#     action      = "listKeys"
#     response_export_values = ["keys"]
#   }

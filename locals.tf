locals {
  # tflint-ignore: terraform_unused_declarations
  avm_azapi_header = join(" ", [for k, v in local.avm_azapi_headers : "${k}=${v}"])
  avm_azapi_headers = !var.enable_telemetry ? {} : (local.fork_avm ? {
    fork_avm  = "true"
    random_id = one(random_uuid.telemetry).result
    } : {
    avm                = "true"
    random_id          = one(random_uuid.telemetry).result
    avm_module_source  = one(data.modtm_module_source.telemetry).module_source
    avm_module_version = one(data.modtm_module_source.telemetry).module_version
  })
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
  blob_endpoint = length(var.containers) == 0 ? [] : ["blob"]
  # Custom domain
  custom_domain = var.custom_domain == null ? null : {
    name             = var.custom_domain.name
    useSubDomainName = var.custom_domain.use_subdomain
  }
  # Whether a customer-managed key is configured.
  customer_managed_key_enabled = var.customer_managed_key != null
  # Effective tier parsed back from the resolved SKU name (strips any V2
  # suffix), so tier-aware logic honours `var.account_sku_name` overrides.
  effective_account_tier = replace(split("_", local.sku_name)[0], "V2", "")
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
  endpoints = toset(concat(local.blob_endpoint, local.queue_endpoint, local.table_endpoint))
  extended_location = var.edge_zone == null ? null : {
    name = var.edge_zone
    type = "EdgeZone"
  }
  fork_avm              = !anytrue([for r in local.valid_module_source_regex : can(regex(r, one(data.modtm_module_source.telemetry).module_source))])
  has_management_policy = length(var.storage_management_policy_rule) > 0
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
  main_location           = var.location
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
  queue_endpoint                = length(var.queues) == 0 ? [] : ["queue"]
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
  sku_name       = coalesce(var.account_sku_name, var.provisioned_billing_model_version == "V2" ? "${var.account_tier}V2_${var.account_replication_type}" : "${var.account_tier}_${var.account_replication_type}")
  table_endpoint = length(var.tables) == 0 ? [] : ["table"]
  valid_module_source_regex = [
    "registry.terraform.io/[A|a]zure/.+",
    "registry.opentofu.io/[A|a]zure/.+",
    "git::https://github\\.com/[A|a]zure/.+",
    "git::ssh:://git@github\\.com/[A|a]zure/.+",
  ]
}

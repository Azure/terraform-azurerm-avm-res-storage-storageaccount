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
}

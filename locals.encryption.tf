locals {
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
}

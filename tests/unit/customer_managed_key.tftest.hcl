mock_provider "azapi" {
  mock_resource "azapi_resource" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-cmk-test/providers/Microsoft.Storage/storageAccounts/stcmkunittest"
    }
  }

  mock_data "azapi_resource" {
    defaults = {
      output = {
        properties = {
          vaultUri = "https://kv-cmk-test.vault.azure.net/"
        }
      }
    }
  }
  mock_data "azapi_client_config" {
    defaults = {
      subscription_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000"
    }
  }
}

mock_provider "random" {}

mock_provider "time" {}

variables {
  enable_telemetry = false
  location         = "eastus"
  name             = "stcmkunittest"
  parent_id        = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-cmk-test"
}

run "create_with_microsoft_managed_keys" {
  command = apply

  assert {
    condition     = !can(azapi_resource.this.body.properties.encryption.keySource) && !can(azapi_resource.this.body.properties.encryption.identity) && !can(azapi_resource.this.body.properties.encryption.keyvaultproperties)
    error_message = "The account PUT must leave key selection to Azure, not reset an existing CMK."
  }

  assert {
    condition     = length(azapi_update_resource.customer_managed_key) == 0
    error_message = "No CMK PATCH should be created without a configured key."
  }
  providers = {
    azapi  = azapi
    random = random
    time   = time
  }
}

run "enable_user_assigned_cmk" {
  command = apply

  variables {
    customer_managed_key = {
      key_vault_resource_id = "/subscriptions/00000000-0000-0000-000000000000/resourceGroups/rg-cmk-test/providers/Microsoft.KeyVault/vaults/kv-cmk-test"
      key_name              = "storage"
      key_version           = "version1"
      user_assigned_identity = {
        resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-cmk-test/providers/Microsoft.ManagedIdentity/userAssignedIdentities/id-cmk"
      }
    }
    managed_identities = {
      user_assigned_resource_ids = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-cmk-test/providers/Microsoft.ManagedIdentity/userAssignedIdentities/id-cmk"]
    }
  }

  assert {
    condition     = !can(azapi_resource.this.body.properties.encryption.keySource) && !can(azapi_resource.this.body.properties.encryption.identity) && !can(azapi_resource.this.body.properties.encryption.keyvaultproperties)
    error_message = "The account PUT must not reference the newly associated identity or select a key source."
  }

  assert {
    condition     = azapi_update_resource.customer_managed_key[0].body.properties.encryption.keySource == "Microsoft.Keyvault" && azapi_update_resource.customer_managed_key[0].body.properties.encryption.identity.userAssignedIdentity == tolist(var.managed_identities.user_assigned_resource_ids)[0]
    error_message = "The separate PATCH must select CMK with the configured user-assigned identity."
  }

  assert {
    condition     = azapi_update_resource.customer_managed_key[0].body.properties.encryption.keyvaultproperties == { keyname = "storage", keyvaulturi = "https://kv-cmk-test.vault.azure.net/", keyversion = "version1" }
    error_message = "The CMK PATCH must include the complete Key Vault key reference."
  }
  providers = {
    azapi  = azapi
    random = random
    time   = time
  }
}

run "enable_system_assigned_cmk" {
  command = apply

  variables {
    customer_managed_key = {
      key_vault_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-cmk-test/providers/Microsoft.KeyVault/vaults/kv-cmk-test"
      key_name              = "storage"
    }
    managed_identities = {
      system_assigned = true
    }
    infrastructure_encryption_enabled = true
    queue_encryption_key_type         = "Account"
    table_encryption_key_type         = "Account"
  }

  assert {
    condition     = azapi_update_resource.customer_managed_key[0].body.properties.encryption.identity == null && azapi_update_resource.customer_managed_key[0].body.properties.encryption.keyvaultproperties.keyversion == null
    error_message = "System-assigned CMK must not require a user-assigned identity or a pinned key version."
  }

  assert {
    condition     = azapi_resource.this.body.properties.encryption.requireInfrastructureEncryption && azapi_resource.this.body.properties.encryption.services.queue.keyType == "Account" && azapi_resource.this.body.properties.encryption.services.table.keyType == "Account"
    error_message = "The account PUT must still manage infrastructure and service encryption."
  }
  providers = {
    azapi  = azapi
    random = random
    time   = time
  }
}

run "seed_existing_cmk_state" {
  command   = apply
  state_key = "existing_cmk"

  module {
    source = "./tests/fixtures/customer_managed_key_state"
  }
}

run "update_existing_cmk_state" {
  command   = plan
  state_key = "existing_cmk"

  variables {
    customer_managed_key = {
      key_vault_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-cmk-test/providers/Microsoft.KeyVault/vaults/kv-cmk-test"
      key_name              = "storage"
      user_assigned_identity = {
        resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-cmk-test/providers/Microsoft.ManagedIdentity/userAssignedIdentities/id-cmk"
      }
    }
    managed_identities = {
      user_assigned_resource_ids = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-cmk-test/providers/Microsoft.ManagedIdentity/userAssignedIdentities/id-cmk"]
    }
    tags = {
      regression = "cmk-update"
    }
  }

  assert {
    condition     = azapi_resource.this.id == run.seed_existing_cmk_state.resource_id
    error_message = "An existing CMK account must be updated in place."
  }

  assert {
    condition     = !can(azapi_resource.this.body.properties.encryption.keySource) && !can(azapi_resource.this.body.properties.encryption.identity) && !can(azapi_resource.this.body.properties.encryption.keyvaultproperties)
    error_message = "The first PUT from pre-existing CMK state must not send an incomplete CMK block or reset key selection."
  }
  providers = {
    azapi  = azapi
    random = random
    time   = time
  }
}

run "remove_cmk_configuration" {
  command   = plan
  state_key = "existing_cmk"

  variables {
    managed_identities = {
      user_assigned_resource_ids = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-cmk-test/providers/Microsoft.ManagedIdentity/userAssignedIdentities/id-cmk"]
    }
  }

  assert {
    condition     = !can(azapi_resource.this.body.properties.encryption.keySource) && length(azapi_update_resource.customer_managed_key) == 0
    error_message = "Removing CMK configuration must not send Microsoft.Storage or take ownership of key selection."
  }
  providers = {
    azapi  = azapi
    random = random
    time   = time
  }
}

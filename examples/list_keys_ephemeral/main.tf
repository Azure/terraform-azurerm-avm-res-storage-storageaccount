terraform {
  required_version = ">= 1.10.0"

  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.8"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.37.0, < 5.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5.0, < 4.0.0"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.9.0, < 1.0.0"
    }
  }
}

provider "azapi" {}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  resource_provider_registrations = "none"
  storage_use_azuread             = true
}

locals {
  test_regions = ["eastus", "eastus2", "westus2", "westus3"]
}

data "azurerm_client_config" "current" {}

resource "random_integer" "region_index" {
  max = length(local.test_regions) - 1
  min = 0
}

resource "random_string" "this" {
  length  = 6
  special = false
  upper   = false
}

module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.0"
}

resource "azapi_resource" "resource_group" {
  location               = local.test_regions[random_integer.region_index.result]
  name                   = module.naming.resource_group.name_unique
  parent_id              = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  type                   = "Microsoft.Resources/resourceGroups@2025-04-01"
  response_export_values = []
}

module "this" {
  source = "../.."

  location  = azapi_resource.resource_group.location
  name      = module.naming.storage_account.name_unique
  parent_id = azapi_resource.resource_group.id
  containers = {
    blob_container0 = {
      name = "blob-container-${random_string.this.result}-0"
    }
  }
  # Shared-key access is left enabled here purely so the listKeys action has
  # something to return. Set this to false for any workload that can use
  # Entra ID authentication instead.
  shared_access_key_enabled = true
}

# Key Vault to receive the key. Uses the AVM Key Vault module so the example
# stays consistent with the rest of the repository.
module "avm_res_keyvault_vault" {
  source  = "Azure/avm-res-keyvault-vault/azurerm"
  version = "0.5.1"

  location            = azapi_resource.resource_group.location
  name                = module.naming.key_vault.name_unique
  resource_group_name = azapi_resource.resource_group.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  network_acls = {
    default_action = "Allow"
  }
  role_assignments = {
    deployment_user_secrets = {
      role_definition_id_or_name = "Key Vault Administrator"
      principal_id               = data.azurerm_client_config.current.object_id
    }
  }
  wait_for_rbac_before_secret_operations = {
    create = "60s"
  }
}

# Read the storage account access keys at apply time without ever writing
# them to Terraform state.
ephemeral "azapi_resource_action" "storage_keys" {
  action                 = "listKeys"
  resource_id            = module.this.resource_id
  type                   = "Microsoft.Storage/storageAccounts@2025-06-01"
  response_export_values = ["keys"]
}

# Park the primary key in Key Vault using a write-only attribute so the value
# never appears in state. Bump `value_wo_version` whenever the upstream key is
# rotated to force the secret to be re-written.
resource "azurerm_key_vault_secret" "primary_key" {
  key_vault_id     = module.avm_res_keyvault_vault.resource.id
  name             = "${module.naming.storage_account.name_unique}-primary-key"
  value_wo         = ephemeral.azapi_resource_action.storage_keys.output.keys[0].value
  value_wo_version = "1"
}

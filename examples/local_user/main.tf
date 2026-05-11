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
  }
}

locals {
  test_regions = ["eastus", "eastus2", "westus2", "westus3"]
}

resource "random_integer" "region_index" {
  max = length(local.test_regions) - 1
  min = 0
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

resource "random_string" "this" {
  length  = 6
  special = false
  upper   = false
}

module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.0"
}

data "azurerm_client_config" "current" {}

resource "azapi_resource" "resource_group" {
  location               = local.test_regions[random_integer.region_index.result]
  name                   = module.naming.resource_group.name_unique
  parent_id              = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  type                   = "Microsoft.Resources/resourceGroups@2025-04-01"
  response_export_values = []
}

resource "azapi_resource" "virtual_network" {
  location  = azapi_resource.resource_group.location
  name      = module.naming.virtual_network.name_unique
  parent_id = azapi_resource.resource_group.id
  type      = "Microsoft.Network/virtualNetworks@2025-05-01"
  body = {
    properties = {
      addressSpace = {
        addressPrefixes = ["192.168.0.0/16"]
      }
    }
  }
  response_export_values = []
}

resource "azapi_resource" "network_security_group" {
  location  = azapi_resource.resource_group.location
  name      = module.naming.network_security_group.name_unique
  parent_id = azapi_resource.resource_group.id
  type      = "Microsoft.Network/networkSecurityGroups@2025-05-01"
  body = {
    properties = {}
  }
  response_export_values = []
}

resource "azapi_resource" "subnet" {
  name      = module.naming.subnet.name_unique
  parent_id = azapi_resource.virtual_network.id
  type      = "Microsoft.Network/virtualNetworks/subnets@2025-05-01"
  body = {
    properties = {
      addressPrefix = "192.168.0.0/24"
      serviceEndpoints = [
        { service = "Microsoft.Storage" }
      ]
      networkSecurityGroup = {
        id = azapi_resource.network_security_group.id
      }
    }
  }
  response_export_values = []
}

resource "azapi_resource" "no_internet_rule" {
  name      = module.naming.network_security_rule.name_unique
  parent_id = azapi_resource.network_security_group.id
  type      = "Microsoft.Network/networkSecurityGroups/securityRules@2025-05-01"
  body = {
    properties = {
      access                   = "Deny"
      direction                = "Outbound"
      priority                 = 100
      protocol                 = "*"
      sourceAddressPrefix      = "192.168.0.0/24"
      sourcePortRange          = "*"
      destinationAddressPrefix = "Internet"
      destinationPortRange     = "*"
    }
  }
  response_export_values = []
}

resource "azapi_resource" "example_identity" {
  location               = azapi_resource.resource_group.location
  name                   = module.naming.user_assigned_identity.name_unique
  parent_id              = azapi_resource.resource_group.id
  type                   = "Microsoft.ManagedIdentity/userAssignedIdentities@2024-11-30"
  body                   = {}
  response_export_values = ["properties"]
}

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

    customer_managed_key = {
      role_definition_id_or_name = "Key Vault Crypto Officer"
      principal_id               = azapi_resource.example_identity.output.properties.principalId
    }
  }
  tags = {
    Dep = "IT"
  }
  wait_for_rbac_before_secret_operations = {
    create = "60s"
  }
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
    blob_container1 = {
      name = "blob-container-${random_string.this.result}-1"
    }
  }
  infrastructure_encryption_enabled = true
  is_hns_enabled                    = true
  local_user = {
    user1 = {
      name                 = "localuser${random_string.this.result}"
      ssh_password_enabled = true

      permission_scopes = {
        blob_scope = {
          service       = "blob"
          resource_type = "container"
          resource_name = "blob-container-${random_string.this.result}-0"
          permissions   = "rwdl"
        }
        file_scope = {
          service       = "file"
          resource_type = "share"
          resource_name = "share-${random_string.this.result}-0"
          permissions   = "rwdl"
        }
      }
    }
  }
  local_user_enabled = true
  managed_identities = {
    system_assigned            = true
    user_assigned_resource_ids = [azapi_resource.example_identity.id]
  }
  network_rules = {
    virtual_network_subnet_ids = toset([azapi_resource.subnet.id])
  }
  public_network_access_enabled = false
  queues = {
    queue0 = {
      name = "queue-${random_string.this.result}-0"
    }
    queue1 = {
      name = "queue-${random_string.this.result}-1"
    }
  }
  role_assignments = {
    role_assignment_1 = {
      role_definition_id_or_name       = "Contributor"
      principal_id                     = coalesce(var.msi_id, data.azurerm_client_config.current.object_id)
      skip_service_principal_aad_check = false
    },
    role_assignment_2 = {
      role_definition_id_or_name       = "Owner"
      principal_id                     = data.azurerm_client_config.current.object_id
      skip_service_principal_aad_check = false
    },
  }
  sftp_enabled              = true
  shared_access_key_enabled = true
  tags = {
    env   = "Dev"
    owner = "John Doe"
    dept  = "IT"
  }
}

# Generate the SSH password for the local user. The Storage RP only returns the
# password from the regeneratePassword action; listKeys returns an empty body
# because Azure does not persist the password server-side. We invoke
# regeneratePassword via a managed azapi_resource_action so the action runs once
# at create (not on every plan/apply, which would rotate the password) and the
# returned value can be consumed by downstream resources.
resource "azapi_resource_action" "regenerate_local_user_password" {
  action                 = "regeneratePassword"
  method                 = "POST"
  resource_id            = module.this.local_users["user1"].id
  type                   = "Microsoft.Storage/storageAccounts/localUsers@2025-06-01"
  response_export_values = ["sshPassword"]

  depends_on = [module.this]
}

# Store the password in Key Vault. Using value_wo keeps the secret value out of
# the azurerm_key_vault_secret state; value_wo_version stays stable so the
# secret is written once and not re-applied on every plan.
resource "azurerm_key_vault_secret" "sftp_password" {
  key_vault_id     = module.avm_res_keyvault_vault.resource.id
  name             = module.this.local_users["user1"].name
  value_wo         = azapi_resource_action.regenerate_local_user_password.output.sshPassword
  value_wo_version = "1"

  depends_on = [module.avm_res_keyvault_vault]
}

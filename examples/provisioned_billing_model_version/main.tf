terraform {
  required_version = ">= 1.10.0"

  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.8"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5.0, < 4.0.0"
    }
  }
}
provider "azapi" {}

locals {
  test_regions = ["eastus", "eastus2", "westus2", "westus3"]
}
# We need this to get the object_id of the current user
data "azapi_client_config" "current" {}
# This allows us to randomize the region for the resource group.
resource "random_integer" "region_index" {
  max = length(local.test_regions) - 1
  min = 0
}

# This allow use to randomize the name of resources
resource "random_string" "this" {
  length  = 6
  special = false
  upper   = false
}
# This ensures we have unique CAF compliant names for resources.
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.0"
}

# This is required for resource modules
resource "azapi_resource" "resource_group" {
  location  = local.test_regions[random_integer.region_index.result]
  name      = module.naming.resource_group.name_unique
  parent_id = "/subscriptions/${data.azapi_client_config.current.subscription_id}"
  type      = "Microsoft.Resources/resourceGroups@2021-04-01"
}

resource "azapi_resource" "virtual_network" {
  location  = azapi_resource.resource_group.location
  name      = module.naming.virtual_network.name_unique
  parent_id = azapi_resource.resource_group.id
  type      = "Microsoft.Network/virtualNetworks@2023-11-01"
  body = {
    properties = {
      addressSpace = {
        addressPrefixes = ["192.168.0.0/16"]
      }
    }
  }
}

resource "azapi_resource" "network_security_group" {
  location  = azapi_resource.resource_group.location
  name      = module.naming.network_security_group.name_unique
  parent_id = azapi_resource.resource_group.id
  type      = "Microsoft.Network/networkSecurityGroups@2023-11-01"
  body = {
    properties = {}
  }
}

resource "azapi_resource" "subnet" {
  name      = module.naming.subnet.name_unique
  parent_id = azapi_resource.virtual_network.id
  type      = "Microsoft.Network/virtualNetworks/subnets@2023-11-01"
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
}

resource "azapi_resource" "no_internet_rule" {
  name      = module.naming.network_security_rule.name_unique
  parent_id = azapi_resource.network_security_group.id
  type      = "Microsoft.Network/networkSecurityGroups/securityRules@2023-11-01"
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
}

resource "azapi_resource" "example_identity" {
  location  = azapi_resource.resource_group.location
  name      = module.naming.user_assigned_identity.name_unique
  parent_id = azapi_resource.resource_group.id
  type      = "Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31"
  body      = {}
}

module "this" {
  source = "../.."

  location         = azapi_resource.resource_group.location
  name             = module.naming.storage_account.name_unique
  parent_id        = azapi_resource.resource_group.id
  account_kind     = "FileStorage"
  account_sku_name = "PremiumV2_ZRS"
  azure_files_authentication = {
    default_share_level_permission = "StorageFileDataSmbShareReader"
    directory_type                 = "AADKERB"
  }
  infrastructure_encryption_enabled = true
  managed_identities = {
    system_assigned            = true
    user_assigned_resource_ids = [azapi_resource.example_identity.id]
  }
  network_rules = {
    virtual_network_subnet_ids = toset([azapi_resource.subnet.id])
  }
  public_network_access_enabled = false
  role_assignments = {
    role_assignment_1 = {
      role_definition_id_or_name       = "Contributor"
      principal_id                     = coalesce(var.msi_id, data.azapi_client_config.current.object_id)
      skip_service_principal_aad_check = false
    },
    role_assignment_2 = {
      role_definition_id_or_name       = "Owner"
      principal_id                     = data.azapi_client_config.current.object_id
      skip_service_principal_aad_check = false
    },

  }
  shared_access_key_enabled = true
  shares = {
    premium_share = {
      name             = "share-${random_string.this.result}-premium"
      quota            = 100
      enabled_protocol = "SMB"
    }
  }
  tags = {
    env   = "Dev"
    owner = "John Doe"
    dept  = "IT"
  }
}

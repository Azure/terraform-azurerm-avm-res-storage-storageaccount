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
resource "azapi_resource" "rg" {
  location  = local.test_regions[random_integer.region_index.result]
  name      = module.naming.resource_group.name_unique
  parent_id = "/subscriptions/${data.azapi_client_config.current.subscription_id}"
  type      = "Microsoft.Resources/resourceGroups@2021-04-01"
}

resource "azapi_resource" "vnet" {
  location  = azapi_resource.rg.location
  name      = module.naming.virtual_network.name_unique
  parent_id = azapi_resource.rg.id
  type      = "Microsoft.Network/virtualNetworks@2023-11-01"
  body = {
    properties = {
      addressSpace = {
        addressPrefixes = ["192.168.0.0/16"]
      }
    }
  }
}

resource "azapi_resource" "nsg" {
  location  = azapi_resource.rg.location
  name      = module.naming.network_security_group.name_unique
  parent_id = azapi_resource.rg.id
  type      = "Microsoft.Network/networkSecurityGroups@2023-11-01"
  body = {
    properties = {}
  }
}

resource "azapi_resource" "subnet" {
  name      = module.naming.subnet.name_unique
  parent_id = azapi_resource.vnet.id
  type      = "Microsoft.Network/virtualNetworks/subnets@2023-11-01"
  body = {
    properties = {
      addressPrefix = "192.168.0.0/24"
      serviceEndpoints = [
        { service = "Microsoft.Storage" }
      ]
      networkSecurityGroup = {
        id = azapi_resource.nsg.id
      }
    }
  }
}

resource "azapi_resource" "no_internet_rule" {
  name      = module.naming.network_security_rule.name_unique
  parent_id = azapi_resource.nsg.id
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

module "public_ip" {
  source  = "lonegunmanb/public-ip/lonegunmanb"
  version = "0.1.0"
  count   = var.bypass_ip_cidr == null ? 1 : 0
}

resource "azapi_resource" "example_identity" {
  location  = azapi_resource.rg.location
  name      = module.naming.user_assigned_identity.name_unique
  parent_id = azapi_resource.rg.id
  type      = "Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31"
  body      = {}
}

module "this" {
  source = "../.."

  location                 = azapi_resource.rg.location
  name                     = module.naming.storage_account.name_unique
  parent_id                = azapi_resource.rg.id
  account_kind             = "StorageV2"
  account_replication_type = "ZRS"
  account_tier             = "Standard"
  azure_files_authentication = {
    default_share_level_permission = "StorageFileDataSmbShareReader"
    directory_type                 = "AADKERB"
  }
  containers = {
    blob_container0 = {
      name = "blob-container-${random_string.this.result}-0"
      # public_access = "container"
    }
    blob_container1 = {
      name = "blob-container-${random_string.this.result}-1"
      # public_access = "container"

    }

  }
  https_traffic_only_enabled = true
  local_user_enabled         = false
  managed_identities = {
    system_assigned            = true
    user_assigned_resource_ids = [azapi_resource.example_identity.id]
  }
  min_tls_version = "TLS1_2"
  network_rules = {
    bypass                     = ["AzureServices"]
    default_action             = "Deny"
    ip_rules                   = [try(module.public_ip[0].public_ip, var.bypass_ip_cidr)]
    virtual_network_subnet_ids = toset([azapi_resource.subnet.id])
  }
  # allow_nested_items_to_be_public = false
  public_network_access_enabled = false
  queues = {
    queue0 = {
      name = "queue-${random_string.this.result}-0"

    }
    queue1 = {
      name = "queue-${random_string.this.result}-1"

      metadata = {
        key1 = "value1"
        key2 = "value2"
      }
    }
  }
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
    share0 = {
      name  = "share-${random_string.this.result}-0"
      quota = 10
      signed_identifiers = [
        {
          id = "1"
          access_policy = {
            expiry_time = "2025-01-01T00:00:00Z"
            permission  = "r"
            start_time  = "2024-01-01T00:00:00Z"
          }
        }
      ]
    }
    share1 = {
      name        = "share-${random_string.this.result}-1"
      quota       = 10
      access_tier = "Hot"
      metadata = {
        key1 = "value1"
        key2 = "value2"
      }
    }
  }
  tables = {
    table0 = {
      name = "table${random_string.this.result}0"
      signed_identifiers = [
        {
          id = "1"
          access_policy = {
            expiry_time = "2025-01-01T00:00:00Z"
            permission  = "r"
            start_time  = "2024-01-01T00:00:00Z"
          }
        }
      ]
    }
    table1 = {
      name = "table${random_string.this.result}1"

      signed_identifiers = [
        {
          id = "1"
          access_policy = {
            expiry_time = "2025-01-01T00:00:00Z"
            permission  = "r"
            start_time  = "2024-01-01T00:00:00Z"
          }
        }
      ]
    }
  }
  tags = {
    env   = "Dev"
    owner = "John Doe"
    dept  = "IT"
  }
}

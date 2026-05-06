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
# This ensures we have unique CAF compliant names for our resources.
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.0"
}


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

locals {
  endpoints = toset(["blob", "queue", "table", "file"])
}

resource "azapi_resource" "private_dns_zone" {
  for_each = local.endpoints

  location  = "global"
  name      = "privatelink.${each.value}.core.windows.net"
  parent_id = azapi_resource.resource_group.id
  type      = "Microsoft.Network/privateDnsZones@2020-06-01"
  body = {
    properties = {}
  }
  tags = {
    env = "Dev"
  }
}

resource "azapi_resource" "private_dns_link" {
  for_each = azapi_resource.private_dns_zone

  location  = "global"
  name      = "${each.key}_${azapi_resource.virtual_network.name}-link"
  parent_id = each.value.id
  type      = "Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01"
  body = {
    properties = {
      registrationEnabled = false
      virtualNetwork = {
        id = azapi_resource.virtual_network.id
      }
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

#create azure storage account
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
  managed_identities = {
    system_assigned            = true
    user_assigned_resource_ids = [azapi_resource.example_identity.id]
  }
  network_rules = {
    virtual_network_subnet_ids = toset([azapi_resource.subnet.id])
  }
  #create a private endpoint for each endpoint type
  private_endpoints = {
    for endpoint in local.endpoints :
    endpoint => {
      # the name must be set to avoid conflicting resources.
      name                          = "pe-${endpoint}-${module.naming.storage_account.name_unique}"
      subnet_resource_id            = azapi_resource.subnet.id
      subresource_name              = endpoint
      private_dns_zone_resource_ids = [azapi_resource.private_dns_zone[endpoint].id]
      # these are optional but illustrate making well-aligned service connection & NIC names.
      private_service_connection_name = "psc-${endpoint}-${module.naming.storage_account.name_unique}"
      network_interface_name          = "nic-pe-${endpoint}-${module.naming.storage_account.name_unique}"
      inherit_lock                    = false
      tags = {
        env   = "Prod"
        owner = "Matt "
        dept  = "IT"
      }

      role_assignments = {
        role_assignment_1 = {
          role_definition_id_or_name = "Contributor"
          principal_id               = coalesce(var.msi_id, data.azapi_client_config.current.object_id)
        }
      }
    }


  }
  #Whether to manage private DNS zone groups with this module. If set to false, you must manage private DNS zone groups externally, e.g. using Azure Policy.
  private_endpoints_manage_dns_zone_group = true
  public_network_access_enabled           = false
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
      principal_id                     = coalesce(var.msi_id, data.azapi_client_config.current.object_id)
      skip_service_principal_aad_check = false
    },
    role_assignment_2 = {
      role_definition_id_or_name       = "Owner"
      principal_id                     = data.azapi_client_config.current.object_id
      skip_service_principal_aad_check = false
    },

  }
  shares = {
    share0 = {
      name  = "share-${random_string.this.result}-0"
      quota = 10
    }
    share1 = {
      name  = "share-${random_string.this.result}-1"
      quota = 10
    }
  }
  tables = {
    table0 = {
      name = "table${random_string.this.result}0"
    }
    table1 = {
      name = "table${random_string.this.result}1"
    }
  }
  tags = {
    env   = "Dev"
    owner = "John Doe"
    dept  = "IT"
  }
}

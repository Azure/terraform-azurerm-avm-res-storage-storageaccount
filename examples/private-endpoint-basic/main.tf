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

resource "random_integer" "region_index" {
  max = length(local.test_regions) - 1
  min = 0
}

# This ensures we have unique CAF compliant names for our resources.
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.0"
}

# This is the resource group that all the resources will be deployed into.
module "resource_group" {
  source  = "Azure/avm-res-resources-resourcegroup/azurerm"
  version = "0.4.0"

  location = local.test_regions[random_integer.region_index.result]
  name     = module.naming.resource_group.name_unique
}

# A virtual network with a dedicated subnet to host the private endpoint.
module "virtual_network" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "0.19.0"

  address_space    = ["10.0.0.0/16"]
  location         = module.resource_group.location
  name             = module.naming.virtual_network.name_unique
  parent_id        = module.resource_group.resource_id
  enable_telemetry = true
  subnets = {
    private_endpoints = {
      name             = "subnet-private-endpoints"
      address_prefixes = ["10.0.0.0/24"]
    }
  }
}

# The private DNS zone used to resolve the storage account blob endpoint privately.
module "private_dns_zone" {
  source  = "Azure/avm-res-network-privatednszone/azurerm"
  version = "0.5.0"

  domain_name = "privatelink.blob.core.windows.net"
  parent_id   = module.resource_group.resource_id
  virtual_network_links = {
    vnetlink1 = {
      name               = "storage-account"
      virtual_network_id = module.virtual_network.resource_id
    }
  }
}

# The storage account, exposed only through a blob private endpoint.
module "storage_account" {
  source = "../.."

  location  = module.resource_group.location
  name      = module.naming.storage_account.name_unique
  parent_id = module.resource_group.resource_id
  containers = {
    demo = {
      name = "demo"
    }
  }
  enable_telemetry = true
  private_endpoints = {
    primary = {
      private_dns_zone_resource_ids = [module.private_dns_zone.resource_id]
      subnet_resource_id            = module.virtual_network.subnets["private_endpoints"].resource_id
      subresource_name              = "blob"
    }
  }
  public_network_access_enabled = false
}

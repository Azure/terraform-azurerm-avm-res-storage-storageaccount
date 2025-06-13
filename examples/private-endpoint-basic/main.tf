
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }

  required_version = ">= 1.11"
}

provider "azurerm" {
  features {}
  storage_use_azuread = true
}

resource "random_string" "this" {
  length  = 3
  numeric = false
  special = false
  upper   = false
}

locals {
  storage_account_name = "stoavmdevswe001${random_string.this.result}"
}

module "resource_group" {
  source  = "Azure/avm-res-resources-resourcegroup/azurerm"
  version = "0.2.1"

  location = var.location
  name     = "rg-avm-dev-swedencentral-001"
}

module "virtual_network" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "0.8.1"

  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = module.resource_group.name
  enable_telemetry    = true
  name                = "vnet-avm-dev-swedencentral-001"
  subnets = {
    private_endpoints = {
      name             = "subnet-private-endpoints"
      address_prefixes = ["10.0.0.0/24"]
    }
  }
}

module "private_dns_zone" {
  source  = "Azure/avm-res-network-privatednszone/azurerm"
  version = "0.3.2"

  domain_name         = "privatelink.blob.core.windows.net"
  resource_group_name = module.resource_group.name
  virtual_network_links = {
    vnetlink1 = {
      vnetlinkname = "storage-account"
      vnetid       = module.virtual_network.resource_id
    }
  }
}

module "storage_account" {
  #source  = "Azure/avm-res-storage-storageaccount/azurerm"
  #version = "0.5.0"
  source = "../.."

  location            = var.location
  name                = local.storage_account_name
  resource_group_name = module.resource_group.name
  containers = {
    demo = {
      name = "demo"
    }
  }
  private_endpoints = {
    primary = {
      private_dns_zone_resource_ids = [module.private_dns_zone.resource_id]
      subnet_resource_id            = module.virtual_network.subnets["private_endpoints"].resource_id
      subresource_name              = "blob"
    }
  }
}

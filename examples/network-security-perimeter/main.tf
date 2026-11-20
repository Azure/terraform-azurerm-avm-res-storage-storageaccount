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

# The storage account, exposed only through a blob private endpoint.
module "storage_account" {
  source = "../.."

  location                         = module.resource_group.location
  name                             = module.naming.storage_account.name_unique
  parent_id                        = module.resource_group.resource_id
  enable_telemetry                 = true
  public_network_access_enabled    = false
  secure_network_perimeter_enabled = true
}

# A Network Security Perimeter that is going to be assigned to the storage account.
# This example enables access from Databricks Serverless jobs to a secured storage account by service tag
module "avm-res-network-networksecurityperimeter" {
  source  = "Azure/avm-res-network-networksecurityperimeter/azapi"
  version = "0.1.0"

  location            = module.resource_group.location
  name                = module.naming.network_security_group.name # Naming Module does not yet contain network perimeter
  resource_group_name = module.resource_group.name

  access_rules = {
    inbound_databricks = {
      name         = "allow-databricks-serverless-by-tag"
      direction    = "Inbound"
      profile_key  = "databricks"
      service_tags = ["AzureDatabricksServerless.WestEurope"]

    }
  }

  profiles = {
    databricks = {
      name = module.naming.network_security_group.name # Naming Module does not yet contain network perimeter
    }
  }

  resource_associations = {
    storage = {
      private_link_resource_id = module.storage_account.resource_id
      profile_key              = "databricks"
      name                     = "storage_assoc"
      access_mode              = "Enforced"
    }
  }
}

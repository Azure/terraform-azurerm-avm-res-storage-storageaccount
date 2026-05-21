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

data "azapi_client_config" "current" {}

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
  parent_id              = "/subscriptions/${data.azapi_client_config.current.subscription_id}"
  type                   = "Microsoft.Resources/resourceGroups@2025-04-01"
  response_export_values = []
}

# Premium FileStorage is required for SMB multichannel.
module "this" {
  source = "../.."

  location         = azapi_resource.resource_group.location
  name             = module.naming.storage_account.name_unique
  parent_id        = azapi_resource.resource_group.id
  account_kind     = "FileStorage"
  account_sku_name = "Premium_LRS"

  # File service-level settings: soft-delete, SMB multichannel, and CORS.
  file_service_properties = {
    share_retention_policy = {
      enabled = true
      days    = 14
    }
    smb = {
      multichannel_enabled     = true
      versions                 = ["SMB3.0", "SMB3.1.1"]
      channel_encryption_types = ["AES-128-GCM", "AES-256-GCM"]
    }
    cors_rules = [
      {
        allowed_headers    = ["x-ms-meta-data*", "x-ms-meta-target*"]
        allowed_methods    = ["GET", "OPTIONS"]
        allowed_origins    = ["https://example.com"]
        exposed_headers    = ["x-ms-meta-*"]
        max_age_in_seconds = 3600
      }
    ]
  }

  shares = {
    premium_share = {
      name             = "share-${random_string.this.result}"
      quota            = 100
      enabled_protocol = "SMB"
    }
  }
}

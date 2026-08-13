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
  version = "0.4.3"
}

resource "azapi_resource" "resource_group" {
  location               = local.test_regions[random_integer.region_index.result]
  name                   = module.naming.resource_group.name_unique
  parent_id              = "/subscriptions/${data.azapi_client_config.current.subscription_id}"
  type                   = "Microsoft.Resources/resourceGroups@2025-04-01"
  response_export_values = []
}

module "this" {
  source = "../.."

  location  = azapi_resource.resource_group.location
  name      = module.naming.storage_account.name_unique
  parent_id = azapi_resource.resource_group.id
  # Blob service-level settings: versioning, soft-delete, change feed, and point-in-time restore.
  blob_properties = {
    versioning_enabled = true
    change_feed = {
      enabled           = true
      retention_in_days = 14
    }
    delete_retention_policy = {
      enabled = true
      days    = 14
    }
    container_delete_retention_policy = {
      enabled = true
      days    = 14
    }
    restore_policy = {
      enabled = true
      days    = 7
    }
  }
  # File service-level settings: share soft-delete and CORS.
  file_service_properties = {
    share_retention_policy = {
      enabled = true
      days    = 14
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
  # Queue service-level settings: CORS.
  queue_properties = {
    cors_rules = [
      {
        allowed_headers    = ["x-ms-meta-data*", "x-ms-meta-target*"]
        allowed_methods    = ["GET", "OPTIONS", "PUT"]
        allowed_origins    = ["https://example.com"]
        exposed_headers    = ["x-ms-meta-*"]
        max_age_in_seconds = 3600
      }
    ]
  }
  queues = {
    example = {
      name = "example-queue-${random_string.this.result}"
    }
  }
  # Table service-level settings: CORS.
  table_properties = {
    cors_rules = [
      {
        allowed_headers    = ["x-ms-meta-data*", "x-ms-meta-target*"]
        allowed_methods    = ["GET", "OPTIONS", "PUT"]
        allowed_origins    = ["https://example.com"]
        exposed_headers    = ["x-ms-meta-*"]
        max_age_in_seconds = 3600
      }
    ]
  }
}

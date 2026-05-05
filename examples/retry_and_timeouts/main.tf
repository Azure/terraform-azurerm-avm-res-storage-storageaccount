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
  numeric = false
  special = false
  upper   = false
}

module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.0"
}

resource "azapi_resource" "rg" {
  location  = local.test_regions[random_integer.region_index.result]
  name      = module.naming.resource_group.name_unique
  parent_id = "/subscriptions/${data.azapi_client_config.current.subscription_id}"
  type      = "Microsoft.Resources/resourceGroups@2021-04-01"
}

# This example shows how to inject custom retry semantics and timeouts. The
# values below are deliberately conservative so that intermittent ARM
# throttling errors are retried with exponential back-off rather than failing
# the apply.
module "this" {
  source = "../.."

  location                 = azapi_resource.rg.location
  name                     = module.naming.storage_account.name_unique
  parent_id                = azapi_resource.rg.id
  account_kind             = "StorageV2"
  account_replication_type = "LRS"
  account_tier             = "Standard"
  # Per-item timeout overrides take precedence over the module-level value
  # above. Here we give container-create a longer ceiling because immutability
  # policy creation can be slow.
  containers = {
    long_running_container = {
      name = "container-${random_string.this.result}"
      immutable_storage_with_versioning = {
        enabled = true
      }
      timeouts = {
        create = "90m"
        read   = "5m"
        update = "90m"
        delete = "60m"
      }
    }
  }
  enable_telemetry = var.enable_telemetry
  network_rules = {
    bypass         = ["AzureServices"]
    default_action = "Deny"
  }
  public_network_access_enabled = false
  # Module-wide retry. Applies to every AzAPI resource managed by the module
  # and every submodule (containers, queues, shares, tables, diagnostic
  # settings, private endpoints, management policy, local users, role
  # assignments, Data Lake Gen2 filesystems) unless overridden per-item.
  retry = {
    error_message_regex  = ["TooManyRequests", "ResourceNotFound", "RetryableError"]
    interval_seconds     = 5
    max_interval_seconds = 60
  }
  shared_access_key_enabled = false
  tags = {
    env = "Dev"
  }
  # Module-wide timeouts. Apply to every AzAPI resource managed by the module
  # and every submodule, unless overridden per-item via `<item>.timeouts`.
  timeouts = {
    create = "60m"
    read   = "5m"
    update = "60m"
    delete = "60m"
  }
}

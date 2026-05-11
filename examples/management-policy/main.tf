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
  response_export_values = []
}

module "this" {
  source = "../.."

  location         = azapi_resource.resource_group.location
  name             = module.naming.storage_account.name_unique
  parent_id        = azapi_resource.resource_group.id
  account_sku_name = "Standard_GRS"
  containers = {
    blob_container0 = {
      name = "blob-container-${random_string.this.result}-0"
    }
    blob_container1 = {
      name = "blob-container-${random_string.this.result}-1"
    }
  }
  managed_identities = {
    system_assigned = true
    user_assigned_resource_ids = [
      azapi_resource.example_identity.id
    ]
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
  storage_management_policy_rule = {
    rule = {
      enabled = true
      name    = "rule1"
      actions = {
        base_blob = {
          #         delete_after_days_since_creation_greater_than = 30
          #         delete_after_days_since_modification_greater_than = 30
          #         tier_to_archive_after_days_since_last_access_time_greater_than = 30
          #         tier_to_archive_after_days_since_modification_greater_than = 30
          #         tier_to_cold_after_days_since_last_access_time_greater_than = 30
          #         tier_to_cold_after_days_since_modification_greater_than = 30
          #         tier_to_cool_after_days_since_creation_greater_than = 30
          #       tier_to_cool_after_days_since_modification_greater_than = 30
          auto_tier_to_hot_from_cool_enabled = false
          #         delete_after_days_since_creation_greater_than = 30
          delete_after_days_since_modification_greater_than      = 30
          tier_to_archive_after_days_since_creation_greater_than = 30
          #         tier_to_archive_after_days_since_last_access_time_greater_than = 30
          tier_to_archive_after_days_since_last_tier_change_greater_than = 30
          #         tier_to_archive_after_days_since_modification_greater_than = 30
          tier_to_cold_after_days_since_creation_greater_than = 30
          #         tier_to_cold_after_days_since_last_access_time_greater_than = 30
          #         tier_to_cold_after_days_since_modification_greater_than = 30
          #         tier_to_cool_after_days_since_creation_greater_than = 30
          tier_to_cool_after_days_since_modification_greater_than = 30
        }
        #         snapshot = {
        #           change_tier_to_archive_after_days_since_creation               = 30
        #           change_tier_to_cool_after_days_since_creation                  = 30
        #           delete_after_days_since_creation_greater_than                  = 30
        #           tier_to_archive_after_days_since_last_tier_change_greater_than = 30
        #           tier_to_cold_after_days_since_creation_greater_than            = 30
        #         }
        #         version = {
        #           change_tier_to_archive_after_days_since_creation               = 30
        #           change_tier_to_cool_after_days_since_creation                  = 30
        #           delete_after_days_since_creation                               = 30
        #           tier_to_archive_after_days_since_last_tier_change_greater_than = 30
        #           tier_to_cold_after_days_since_creation_greater_than            = 30
        #         }
      }
      filters = {
        blob_types   = ["blockBlob"]
        prefix_match = ["test"]
        match_blob_index_tag = [
          {
            name      = "tag1"
            operation = "=="
            value     = "value1"
          }
        ]
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

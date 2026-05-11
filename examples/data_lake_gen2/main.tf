terraform {
  required_version = ">= 1.10.0"

  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.8"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.37.0, < 5.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5.0, < 4.0.0"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.9.0, < 1.0.0"
    }
  }
}

provider "azapi" {}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  resource_provider_registrations = "none"
  storage_use_azuread             = true
}

locals {
  test_regions = ["eastus", "eastus2", "westus2", "westus3"]
}

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

data "azurerm_client_config" "current" {}

resource "azapi_resource" "resource_group" {
  location               = local.test_regions[random_integer.region_index.result]
  name                   = module.naming.resource_group.name_unique
  parent_id              = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  type                   = "Microsoft.Resources/resourceGroups@2021-04-01"
  response_export_values = []
}

resource "azapi_resource" "example_identity" {
  location               = azapi_resource.resource_group.location
  name                   = module.naming.user_assigned_identity.name_unique
  parent_id              = azapi_resource.resource_group.id
  type                   = "Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31"
  body                   = {}
  response_export_values = []
}

module "this" {
  source = "../.."

  location  = azapi_resource.resource_group.location
  name      = module.naming.storage_account.name_unique
  parent_id = azapi_resource.resource_group.id
  azure_files_authentication = {
    default_share_level_permission = "StorageFileDataSmbShareReader"
    directory_type                 = "AADKERB"
  }
  is_hns_enabled = true
  managed_identities = {
    system_assigned            = true
    user_assigned_resource_ids = [azapi_resource.example_identity.id]
  }
  # Data Lake Gen2 path resources require data plane access; allow public access.
  network_rules                 = null
  public_network_access_enabled = true
  role_assignments = {
    role_assignment_1 = {
      role_definition_id_or_name       = "Contributor"
      principal_id                     = coalesce(var.msi_id, data.azurerm_client_config.current.object_id)
      skip_service_principal_aad_check = false
    }
    role_assignment_2 = {
      role_definition_id_or_name       = "Owner"
      principal_id                     = data.azurerm_client_config.current.object_id
      skip_service_principal_aad_check = false
    }
    role_assignment_3 = {
      role_definition_id_or_name       = "Storage Blob Data Owner"
      principal_id                     = data.azurerm_client_config.current.object_id
      skip_service_principal_aad_check = false
    }
  }
  shared_access_key_enabled = true
  storage_data_lake_gen2_filesystems = {
    data_lake_1 = {
      name = "datalake1"
    }
    data_lake_2 = {
      name = "datalake2"
    }
  }
  tags = {
    env   = "Dev"
    owner = "John Doe"
    dept  = "IT"
  }
}

# v1.0.0 BREAKING CHANGE: This module no longer manages the Data Lake Gen2
# data-plane (POSIX ACLs, owner/group, paths). To continue managing these
# features, declare the azurerm-provider resources directly alongside this
# module. The example below mirrors the pre-1.0.0 input shape using
# `azurerm_storage_data_lake_gen2_path` resources, plus shows how to set the
# owner/group/ace on a filesystem via the new
# `azurerm_storage_data_lake_gen2_filesystem` data source.
#
# Note: requires the azurerm provider in the consuming root module. AzAPI
# does not currently expose the DFS data-plane API needed for these
# operations, so they remain on the azurerm provider.

# Wait for the storage account RBAC role assignments to take effect before
# making data-plane calls. Otherwise the Storage Blob Data Owner permission
# may not be propagated yet and `azurerm_storage_data_lake_gen2_path` will
# fail with an authorization error.
resource "time_sleep" "wait_for_rbac" {
  create_duration = "30s"

  depends_on = [module.this]
}

# Companion: ACL/owner/group on a filesystem root. We use the azurerm
# resource directly (NOT the dropped `ace`/`owner`/`group` fields on the
# module input) so the data-plane call is performed against the storage
# account managed by this module.
resource "azurerm_storage_data_lake_gen2_path" "directory_with_acl" {
  filesystem_name    = "datalake1"
  path               = "example-directory"
  resource           = "directory"
  storage_account_id = module.this.resource_id
  group              = "$superuser"
  owner              = data.azurerm_client_config.current.object_id

  ace {
    permissions = "rwx"
    type        = "user"
    id          = data.azurerm_client_config.current.object_id
  }
  ace {
    permissions = "r-x"
    type        = "group"
  }
  ace {
    permissions = "---"
    type        = "other"
  }

  depends_on = [time_sleep.wait_for_rbac]
}

resource "azurerm_storage_data_lake_gen2_path" "data_directory" {
  filesystem_name    = "datalake2"
  path               = "data"
  resource           = "directory"
  storage_account_id = module.this.resource_id
  owner              = "$superuser"

  depends_on = [time_sleep.wait_for_rbac]
}

resource "azurerm_storage_data_lake_gen2_path" "logs_directory" {
  filesystem_name    = "datalake2"
  path               = "logs"
  resource           = "directory"
  storage_account_id = module.this.resource_id

  depends_on = [time_sleep.wait_for_rbac]
}

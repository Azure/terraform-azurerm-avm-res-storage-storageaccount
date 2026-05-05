terraform {
  required_version = ">= 1.10.0"

  required_providers {
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
resource "azurerm_resource_group" "this" {
  location = local.test_regions[random_integer.region_index.result]
  name     = module.naming.resource_group.name_unique
}

resource "azurerm_virtual_network" "vnet" {
  location            = azurerm_resource_group.this.location
  name                = module.naming.virtual_network.name_unique
  resource_group_name = azurerm_resource_group.this.name
  address_space       = ["192.168.0.0/16"]
}

resource "azurerm_subnet" "private" {
  address_prefixes     = ["192.168.0.0/24"]
  name                 = module.naming.subnet.name_unique
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  service_endpoints    = ["Microsoft.Storage"]
}

resource "azurerm_network_security_group" "nsg" {
  location            = azurerm_resource_group.this.location
  name                = module.naming.network_security_group.name_unique
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_subnet_network_security_group_association" "private" {
  network_security_group_id = azurerm_network_security_group.nsg.id
  subnet_id                 = azurerm_subnet.private.id
}

resource "azurerm_network_security_rule" "no_internet" {
  access                      = "Deny"
  direction                   = "Outbound"
  name                        = module.naming.network_security_rule.name_unique
  network_security_group_name = azurerm_network_security_group.nsg.name
  priority                    = 100
  protocol                    = "*"
  resource_group_name         = azurerm_resource_group.this.name
  destination_address_prefix  = "Internet"
  destination_port_range      = "*"
  source_address_prefix       = azurerm_subnet.private.address_prefixes[0]
  source_port_range           = "*"
}

module "public_ip" {
  source  = "lonegunmanb/public-ip/lonegunmanb"
  version = "0.1.0"
  count   = var.bypass_ip_cidr == null ? 1 : 0
}
# We need this to get the object_id of the current user
data "azurerm_client_config" "current" {}

resource "azurerm_user_assigned_identity" "example_identity" {
  location            = azurerm_resource_group.this.location
  name                = module.naming.user_assigned_identity.name_unique
  resource_group_name = azurerm_resource_group.this.name
}
# We use the role definition data source to get the id of the Contributor role
data "azurerm_role_definition" "example" {
  name = "Contributor"
}

module "this" {
  source = "../.."

  location                 = azurerm_resource_group.this.location
  name                     = module.naming.storage_account.name_unique
  parent_id                = azurerm_resource_group.this.id
  account_kind             = "StorageV2"
  account_replication_type = "ZRS"
  account_tier             = "Standard"
  azure_files_authentication = {
    default_share_level_permission = "StorageFileDataSmbShareReader"
    directory_type                 = "AADKERB"
  }
  https_traffic_only_enabled = true
  is_hns_enabled             = true
  managed_identities = {
    system_assigned            = true
    user_assigned_resource_ids = [azurerm_user_assigned_identity.example_identity.id]
  }
  min_tls_version = "TLS1_2"
  network_rules = {
    bypass                     = ["AzureServices"]
    default_action             = "Deny"
    ip_rules                   = [try(module.public_ip[0].public_ip, var.bypass_ip_cidr)]
    virtual_network_subnet_ids = toset([azurerm_subnet.private.id])
  }
  public_network_access_enabled = true
  role_assignments = {
    role_assignment_1 = {
      role_definition_id_or_name       = data.azurerm_role_definition.example.name
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

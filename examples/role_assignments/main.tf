terraform {
  required_version = ">= 1.7.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.7.0, < 5.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5.0, < 4.0.0"
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

# This allows us to randomize the region for the resource group.
locals {
  test_regions = ["eastus", "eastus2", "westus2", "westus3"]
}
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
# This ensures we have unique CAF compliant names for resources.
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.0"
}


resource "azurerm_resource_group" "this" {
  location = local.test_regions[random_integer.region_index.result]
  name     = module.naming.resource_group.name_unique
}

resource "azurerm_virtual_network" "vnet" {
  address_space       = ["192.168.0.0/16"]
  location            = azurerm_resource_group.this.location
  name                = module.naming.virtual_network.name_unique
  resource_group_name = azurerm_resource_group.this.name
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
  resource_group_name      = azurerm_resource_group.this.name
  account_kind             = "StorageV2"
  account_replication_type = "ZRS"
  account_tier             = "Standard"
  containers = {
    blob_container0 = {
      name = "blob-container-${random_string.this.result}-0"
      role_assignments = {
        rbac_storage_blob_data_contributor = {
          role_definition_id_or_name = "Storage Blob Data Contributor"
          principal_id               = data.azurerm_client_config.current.object_id
        }
      }
    }
    blob_container1 = {
      name = "blob-container-${random_string.this.result}-1"
      role_assignments = {
        rbac_storage_blob_data_reader = {
          role_definition_id_or_name = "Storage Blob Data Reader"
          principal_id               = data.azurerm_client_config.current.object_id
        }
      }
    }

  }
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
  queues = {
    queue0 = {
      name = "queue-${random_string.this.result}-0"
      role_assignments = {
        rbac_storage_queue_data_reader = {
          role_definition_id_or_name = "Storage Queue Data Reader"
          principal_id               = data.azurerm_client_config.current.object_id
        }
      }
    }
    queue1 = {
      name = "queue-${random_string.this.result}-1"
      role_assignments = {
        rbac_storage_queue_data_contributor = {
          role_definition_id_or_name = "Storage Queue Data Contributor"
          principal_id               = data.azurerm_client_config.current.object_id
        }
      }
    }
  }
  role_assignments = {
    role_assignment_1 = {
      role_definition_id_or_name       = data.azurerm_role_definition.example.name
      principal_id                     = coalesce(var.msi_id, data.azurerm_client_config.current.object_id)
      skip_service_principal_aad_check = false
    },
    role_assignment_2 = {
      role_definition_id_or_name       = "Owner"
      principal_id                     = data.azurerm_client_config.current.object_id
      skip_service_principal_aad_check = false
    },

  }
  shared_access_key_enabled = true
  shares = {
    share0 = {
      name  = "share-${random_string.this.result}-0"
      quota = 10
      role_assignments = {
        rbac_storage_share_data_reader = {
          role_definition_id_or_name = "Storage File Data SMB Share Reader"
          principal_id               = data.azurerm_client_config.current.object_id
        }
      }
    }
    share1 = {
      name  = "share-${random_string.this.result}-1"
      quota = 10
      role_assignments = {
        rbac_storage_share_data_contributor = {
          role_definition_id_or_name = "Storage File Data SMB Share Contributor"
          principal_id               = data.azurerm_client_config.current.object_id
        }
      }
    }
  }
  tables = {
    table0 = {
      name = "table${random_string.this.result}0"
      role_assignments = {
        rbac_storage_table_data_reader = {
          role_definition_id_or_name = "Storage Table Data Reader"
          principal_id               = data.azurerm_client_config.current.object_id
        }
      }
    }
    table1 = {
      name = "table${random_string.this.result}1"
      role_assignments = {
        rbac_storage_table_data_contributor = {
          role_definition_id_or_name = "Storage Table Data Contributor"
          principal_id               = data.azurerm_client_config.current.object_id
        }
      }
    }
  }
  tags = {
    env   = "Dev"
    owner = "John Doe"
    dept  = "IT"
  }
}

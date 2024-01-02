terraform {
  required_version = ">= 1.3.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.63.0, < 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.3.2, < 4.0"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  skip_provider_registration = true
  storage_use_azuread        = false
}

resource "random_string" "this" {
  length  = 6
  special = false
  upper   = false
}

# This ensures we have unique CAF compliant names for our resources.
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.0"
}

# This is required for resource modules
resource "azurerm_resource_group" "this" {
  name     = module.naming.resource_group.name_unique
  location = "AustraliaEast"
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

locals {
  endpoints = toset(["blob", "queue", "table"])
}

module "public_ip" {
  count = var.bypass_ip_cidr == null ? 1 : 0

  source  = "lonegunmanb/public-ip/lonegunmanb"
  version = "0.1.0"
}

resource "azurerm_private_dns_zone" "this" {
  for_each = local.endpoints

  name                = "privatelink.${each.value}.core.windows.net"
  resource_group_name = azurerm_resource_group.this.name
}

module "this" {
  #checkov:skip=CKV_AZURE_34:It's a known issue that Checkov cannot work prefect along with module
  #checkov:skip=CKV_AZURE_35:It's a known issue that Checkov cannot work prefect along with module
  #checkov:skip=CKV2_AZURE_20:It's a known issue that Checkov cannot work prefect along with module
  #checkov:skip=CKV2_AZURE_21:It's a known issue that Checkov cannot work prefect along with module
  source = "../.."

  account_replication_type      = "LRS"
  account_tier                  = "Standard"
  account_kind                  = "StorageV2"
  location                      = azurerm_resource_group.this.location
  name                          = module.naming.storage_account.name_unique
  resource_group_name           = azurerm_resource_group.this.name
  min_tls_version               = "TLS1_2"
  shared_access_key_enabled     = true
  public_network_access_enabled = true

  # TODO re-introduce once the rest is working
  # network_rules = {
  #   bypass                     = ["AzureServices"]
  #   default_action             = "Deny"
  #   ip_rules                   = [try(module.public_ip[0].public_ip, var.bypass_ip_cidr)]
  #   virtual_network_subnet_ids = toset([azurerm_subnet.private.id])
  # }
  containers = {
    blob_container0 = {
      name                  = "blob-container-${random_string.this.result}-0"
      container_access_type = "private"
    }
    blob_container1 = {
      name                  = "blob-container-${random_string.this.result}-1"
      container_access_type = "private"
    }
  }
  queues = {
    queue0 = {
      name = "queue-${random_string.this.result}-0"
    }
    queue1 = {
      name = "queue-${random_string.this.result}-1"
    }
  }
  tables = {
    table0 = {
      name = "table${random_string.this.result}0"
    }
    table1 = {
      name = "table${random_string.this.result}1"
    }
  }

  private_endpoints = {
    for endpoint in local.endpoints :
    endpoint => {
      # the name must be set to avoid conflicting resources.
      name                          = "pe-${endpoint}-${module.naming.storage_account.name_unique}"
      subnet_resource_id            = azurerm_subnet.private.id
      subresource_name              = [endpoint]
      private_dns_zone_resource_ids = [azurerm_private_dns_zone.this[endpoint].id]
      # these are optional but illustrate making well-aligned service connection & NIC names.
      private_service_connection_name = "psc-${endpoint}-${module.naming.storage_account.name_unique}"
      network_interface_name          = "nic-pe-${endpoint}-${module.naming.storage_account.name_unique}"
    }
  }

}

resource "azurerm_log_analytics_storage_insights" "this" {
  name                 = "si-${module.naming.log_analytics_workspace.name_unique}"
  resource_group_name  = azurerm_resource_group.this.name
  storage_account_id   = module.this.id
  storage_account_key  = module.this.resource.primary_access_key
  workspace_id         = azurerm_log_analytics_workspace.this.id
  blob_container_names = [for c in module.this.containers : c.name]
  table_names          = [for t in module.this.tables : t.name]

  depends_on = [module.this]
}

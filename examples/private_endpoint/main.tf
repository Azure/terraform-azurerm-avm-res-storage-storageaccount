resource "random_string" "this" {
  length  = 6
  special = false
  upper   = false
}

resource "azurerm_resource_group" "this" {
  location = var.location
  name     = "terraform-azurerm-storage-account-${random_string.this.result}"
}

resource "azurerm_virtual_network" "vnet" {
  address_space       = ["192.168.0.0/16"]
  location            = azurerm_resource_group.this.location
  name                = "vnet"
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_subnet" "private" {
  address_prefixes     = ["192.168.0.0/24"]
  name                 = "private"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  service_endpoints    = ["Microsoft.Storage"]
}

resource "azurerm_network_security_group" "nsg" {
  location            = azurerm_resource_group.this.location
  name                = "private_nsg"
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_subnet_network_security_group_association" "private" {
  network_security_group_id = azurerm_network_security_group.nsg.id
  subnet_id                 = azurerm_subnet.private.id
}

resource "azurerm_network_security_rule" "no_internet" {
  access                      = "Deny"
  direction                   = "Outbound"
  name                        = "no_internet"
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

resource "azurerm_private_dns_zone" "private_links" {
  for_each = local.endpoints

  name                = "privatelink.${each.value}.core.windows.net"
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_private_dns_zone" "public_endpoints" {
  for_each = local.endpoints

  name                = "${each.value}.core.windows.net"
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "private_links" {
  for_each = local.endpoints

  name                  = "${each.value}_${azurerm_virtual_network.vnet.name}_private"
  private_dns_zone_name = azurerm_private_dns_zone.private_links[each.value].name
  resource_group_name   = azurerm_resource_group.this.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}

resource "azurerm_private_dns_zone_virtual_network_link" "public_endpoints" {
  for_each = local.endpoints

  name                  = "${each.value}_${azurerm_virtual_network.vnet.name}_public"
  private_dns_zone_name = azurerm_private_dns_zone.public_endpoints[each.value].name
  resource_group_name   = azurerm_resource_group.this.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}

module "public_ip" {
  count = var.bypass_ip_cidr == null ? 1 : 0

  source  = "lonegunmanb/public-ip/lonegunmanb"
  version = "0.1.0"
}

module "this" {
  #checkov:skip=CKV_AZURE_34:It's a known issue that Checkov cannot work prefect along with module
  #checkov:skip=CKV_AZURE_35:It's a known issue that Checkov cannot work prefect along with module
  #checkov:skip=CKV2_AZURE_20:It's a known issue that Checkov cannot work prefect along with module
  #checkov:skip=CKV2_AZURE_21:It's a known issue that Checkov cannot work prefect along with module
  source = "../.."

  storage_account_account_replication_type = "LRS"
  storage_account_account_tier             = "Standard"
  storage_account_account_kind             = "StorageV2"
  storage_account_location                 = azurerm_resource_group.this.location
  storage_account_name                     = "tfmodstoracc${random_string.this.result}"
  storage_account_resource_group_name      = azurerm_resource_group.this.name
  storage_account_min_tls_version          = "TLS1_2"
  lock = {
    name = "lock"
    kind = "CanNotDelete"
  }

  storage_account_network_rules = {
    bypass                     = ["AzureServices"]
    default_action             = "Deny"
    ip_rules                   = [try(module.public_ip[0].public_ip, var.bypass_ip_cidr)]
    virtual_network_subnet_ids = toset([azurerm_subnet.private.id])
  }
  storage_container = {
    blob_container0 = {
      name                  = "blob-container-${random_string.this.result}-0"
      container_access_type = "private"
    }
    blob_container1 = {
      name                  = "blob-container-${random_string.this.result}-1"
      container_access_type = "private"
    }
  }
  storage_queue = {
    queue0 = {
      name = "queue-${random_string.this.result}-0"
    }
    queue1 = {
      name = "queue-${random_string.this.result}-1"
    }
  }
  storage_table = {
    table0 = {
      name = "table${random_string.this.result}0"
    }
    table1 = {
      name = "table${random_string.this.result}1"
    }
  }
  private_endpoints = {
    subnet_id = azurerm_subnet.private.id
    #lock_level = "None"
    private_service_connection = {
      name_prefix = "pe_"
    }
  }

  private_dns_zones_for_private_link = {
    for endpoint in local.endpoints : endpoint => {
      resource_group_name       = azurerm_resource_group.this.name
      name                      = azurerm_private_dns_zone.private_links[endpoint].name
      virtual_network_link_name = azurerm_private_dns_zone_virtual_network_link.private_links[endpoint].name
      lock_level = "None"
    }

  }

  private_dns_zones_for_public_endpoint = {
    for endpoint in local.endpoints : endpoint => {
      resource_group_name       = azurerm_resource_group.this.name
      name                      = azurerm_private_dns_zone.public_endpoints[endpoint].name
      virtual_network_link_name = azurerm_private_dns_zone_virtual_network_link.public_endpoints[endpoint].name
    }
  }

}


/*
module "another_container" {
  #checkov:skip=CKV_AZURE_34:It's a known issue that Checkov cannot work prefect along with module
  #checkov:skip=CKV_AZURE_35:It's a known issue that Checkov cannot work prefect along with module
  #checkov:skip=CKV2_AZURE_20:It's a known issue that Checkov cannot work prefect along with module
  #checkov:skip=CKV2_AZURE_21:It's a known issue that Checkov cannot work prefect along with module
  source = "../.."

  storage_account_account_replication_type = "LRS"
  storage_account_account_tier             = "Standard"
  storage_account_account_kind             = "StorageV2"
  storage_account_location                 = azurerm_resource_group.this.location
  storage_account_name                     = "tfmodstoracc${random_string.this.result}2"
  storage_account_resource_group_name      = azurerm_resource_group.this.name
  storage_account_min_tls_version          = "TLS1_2"
  storage_account_network_rules = {
    bypass                     = ["AzureServices"]
    default_action             = "Deny"
    ip_rules                   = [try(module.public_ip[0].public_ip, var.bypass_ip_cidr)]
    virtual_network_subnet_ids = toset([azurerm_subnet.private.id])
  }
  storage_container = {
    blob_container = {
      name                  = "another-blob-container-${random_string.this.result}"
      container_access_type = "private"
    }
  }
  private_endpoints = {
    subnet_id = azurerm_subnet.private.id
    private_service_connection = {
      name_prefix = "pe_"
    }
  }
  private_dns_zones_for_private_link = {
    blob = {
      resource_group_name       = azurerm_resource_group.this.name
      name                      = azurerm_private_dns_zone.private_links["blob"].name
      virtual_network_link_name = azurerm_private_dns_zone_virtual_network_link.private_links["blob"].name
    }
  }
  private_dns_zones_for_public_endpoint = {
    blob = {
      resource_group_name       = azurerm_resource_group.this.name
      name                      = azurerm_private_dns_zone.public_endpoints["blob"].name
      virtual_network_link_name = azurerm_private_dns_zone_virtual_network_link.public_endpoints["blob"].name
    }
  }

*/

resource "azurerm_log_analytics_storage_insights" "this" {
  name                 = "storageinsight"
  resource_group_name  = azurerm_resource_group.this.name
  storage_account_id   = module.this.storage_account_id
  storage_account_key  = module.this.storage_account_primary_access_key
  workspace_id         = azurerm_log_analytics_workspace.this.id
  blob_container_names = [for c in module.this.storage_container : c.name]
  table_names          = [for t in module.this.storage_table : t.name]

  depends_on = [module.this]
}

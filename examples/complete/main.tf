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
  endpoints    = toset(["blob", "queue", "table", "file"])
  test_regions = ["eastus", "eastus2", "westus2", "westus3"]
}

data "azapi_client_config" "current" {}

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
    }
  }
  response_export_values = []
}

resource "azapi_resource" "private_endpoint_subnet" {
  name      = "${module.naming.subnet.name_unique}-pe"
  parent_id = azapi_resource.virtual_network.id
  type      = "Microsoft.Network/virtualNetworks/subnets@2025-05-01"
  body = {
    properties = {
      addressPrefix = "192.168.1.0/24"
    }
  }
  response_export_values = []

  depends_on = [azapi_resource.subnet]
}

resource "azapi_resource" "private_dns_zone" {
  for_each = local.endpoints

  location  = "global"
  name      = "privatelink.${each.value}.core.windows.net"
  parent_id = azapi_resource.resource_group.id
  type      = "Microsoft.Network/privateDnsZones@2024-06-01"
  body = {
    properties = {}
  }
  response_export_values = []
  retry = {
    error_message_regex  = ["CannotDeleteResource"]
    interval_seconds     = 15
    max_interval_seconds = 60
  }
}

resource "azapi_resource" "private_dns_link" {
  for_each = azapi_resource.private_dns_zone

  location  = "global"
  name      = "${each.key}_${azapi_resource.virtual_network.name}-link"
  parent_id = each.value.id
  type      = "Microsoft.Network/privateDnsZones/virtualNetworkLinks@2024-06-01"
  body = {
    properties = {
      registrationEnabled = false
      virtualNetwork = {
        id = azapi_resource.virtual_network.id
      }
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

resource "azapi_resource" "log_analytics_workspace" {
  location  = azapi_resource.resource_group.location
  name      = module.naming.log_analytics_workspace.name_unique
  parent_id = azapi_resource.resource_group.id
  type      = "Microsoft.OperationalInsights/workspaces@2025-02-01"
  body = {
    properties = {
      sku = {
        name = "PerGB2018"
      }
    }
  }
  response_export_values = []
}

resource "azapi_resource" "event_hub_namespace" {
  location  = azapi_resource.resource_group.location
  name      = module.naming.eventhub_namespace.name_unique
  parent_id = azapi_resource.resource_group.id
  type      = "Microsoft.EventHub/namespaces@2024-01-01"
  body = {
    sku = {
      name     = "Standard"
      tier     = "Standard"
      capacity = 2
    }
    properties = {
      isAutoInflateEnabled   = true
      maximumThroughputUnits = 3
      minimumTlsVersion      = "1.2"
      zoneRedundant          = true
    }
  }
  response_export_values = []
}

resource "azapi_resource" "event_hub" {
  name      = module.naming.eventhub_namespace.name_unique
  parent_id = azapi_resource.event_hub_namespace.id
  type      = "Microsoft.EventHub/namespaces/eventhubs@2024-01-01"
  body = {
    properties = {
      messageRetentionInDays = 7
      partitionCount         = 2
    }
  }
  response_export_values = []
}

resource "azapi_resource" "event_hub_authorization_rule" {
  name      = module.naming.eventhub_authorization_rule.name_unique
  parent_id = azapi_resource.event_hub.id
  type      = "Microsoft.EventHub/namespaces/eventhubs/authorizationRules@2024-01-01"
  body = {
    properties = {
      rights = ["Listen"]
    }
  }
  response_export_values = []
}

# Fetch the listen key for the event hub authorisation rule (used by an output).
data "azapi_resource_action" "event_hub_auth_rule_keys" {
  action                 = "listKeys"
  resource_id            = azapi_resource.event_hub_authorization_rule.id
  type                   = "Microsoft.EventHub/namespaces/eventhubs/authorizationRules@2024-01-01"
  response_export_values = ["primaryKey", "secondaryKey", "primaryConnectionString", "secondaryConnectionString"]
}

# This example exercises the full surface area of the module:
#   * Containers, queues, file shares (with signed identifiers), and tables.
#   * Per-sub-resource RBAC role assignments (containers/queues/shares/tables).
#   * Storage account level RBAC role assignments.
#   * A user-assigned managed identity plus a system-assigned managed identity.
#   * VNet service-endpoint based network rules and private endpoints with
#     module-managed private DNS zone groups.
#   * Diagnostic settings sent to both Log Analytics and Event Hubs for the
#     storage account itself plus the blob, file, queue, and table services.
#   * Module-wide retry and timeout configuration that propagates to every
#     AzAPI resource and every submodule.
#   * A blob container with longer per-item timeout overrides.
module "this" {
  source = "../.."

  location  = azapi_resource.resource_group.location
  name      = module.naming.storage_account.name_unique
  parent_id = azapi_resource.resource_group.id
  azure_files_authentication = {
    default_share_level_permission = "StorageFileDataSmbShareReader"
    directory_type                 = "AADKERB"
  }
  containers = {
    blob_container0 = {
      name = "blob-container-${random_string.this.result}-0"
      role_assignments = {
        rbac_storage_blob_data_contributor = {
          role_definition_id_or_name = "Storage Blob Data Contributor"
          principal_id               = data.azapi_client_config.current.object_id
        }
      }
    }
    blob_container1 = {
      name = "blob-container-${random_string.this.result}-1"
      role_assignments = {
        rbac_storage_blob_data_reader = {
          role_definition_id_or_name = "Storage Blob Data Reader"
          principal_id               = data.azapi_client_config.current.object_id
        }
      }
    }
    blob_container_long_timeouts = {
      name = "long-timeouts-${random_string.this.result}"
      # Per-item timeout overrides take precedence over the module-wide
      # value below.
      timeouts = {
        create = "90m"
        read   = "5m"
        update = "90m"
        delete = "60m"
      }
    }
  }
  diagnostic_settings_blob = {
    blob = {
      name                                     = "diag"
      workspace_resource_id                    = azapi_resource.log_analytics_workspace.id
      event_hub_name                           = azapi_resource.event_hub.name
      event_hub_authorization_rule_resource_id = "${azapi_resource.event_hub_namespace.id}/authorizationRules/RootManageSharedAccessKey"
      logs = [
        { category = "StorageWrite" },
        { category = "StorageDelete" },
      ]
      metrics = [
        { category = "Transaction" },
      ]
    }
  }
  diagnostic_settings_file = {
    file = {
      name                                     = "diag"
      workspace_resource_id                    = azapi_resource.log_analytics_workspace.id
      event_hub_name                           = azapi_resource.event_hub.name
      event_hub_authorization_rule_resource_id = "${azapi_resource.event_hub_namespace.id}/authorizationRules/RootManageSharedAccessKey"
      logs = [
        { category_group = "audit" },
      ]
      metrics = [
        { category = "Transaction" },
      ]
    }
  }
  diagnostic_settings_queue = {
    queue = {
      name                                     = "diag"
      workspace_resource_id                    = azapi_resource.log_analytics_workspace.id
      event_hub_name                           = azapi_resource.event_hub.name
      event_hub_authorization_rule_resource_id = "${azapi_resource.event_hub_namespace.id}/authorizationRules/RootManageSharedAccessKey"
      logs = [
        { category = "StorageWrite" },
        { category = "StorageDelete" },
      ]
      metrics = [
        { category = "Transaction" },
      ]
    }
  }
  diagnostic_settings_storage_account = {
    storage = {
      name                                     = "diag"
      workspace_resource_id                    = azapi_resource.log_analytics_workspace.id
      event_hub_name                           = azapi_resource.event_hub.name
      event_hub_authorization_rule_resource_id = "${azapi_resource.event_hub_namespace.id}/authorizationRules/RootManageSharedAccessKey"
      metrics = [
        { category = "Transaction" },
      ]
    }
  }
  diagnostic_settings_table = {
    table = {
      name                                     = "diag"
      workspace_resource_id                    = azapi_resource.log_analytics_workspace.id
      event_hub_name                           = azapi_resource.event_hub.name
      event_hub_authorization_rule_resource_id = "${azapi_resource.event_hub_namespace.id}/authorizationRules/RootManageSharedAccessKey"
      logs = [
        { category = "StorageWrite" },
      ]
      metrics = [
        { category = "Transaction" },
      ]
    }
  }
  enable_telemetry = var.enable_telemetry
  managed_identities = {
    system_assigned            = true
    user_assigned_resource_ids = [azapi_resource.example_identity.id]
  }
  network_rules = {
    virtual_network_subnet_ids = toset([azapi_resource.subnet.id])
  }
  private_endpoints = {
    for endpoint in local.endpoints :
    endpoint => {
      name                            = "pe-${endpoint}-${module.naming.storage_account.name_unique}"
      subnet_resource_id              = azapi_resource.private_endpoint_subnet.id
      subresource_name                = endpoint
      private_dns_zone_resource_ids   = [azapi_resource.private_dns_zone[endpoint].id]
      private_service_connection_name = "psc-${endpoint}-${module.naming.storage_account.name_unique}"
      network_interface_name          = "nic-pe-${endpoint}-${module.naming.storage_account.name_unique}"
    }
  }
  public_network_access_enabled = false
  queues = {
    queue0 = {
      name = "queue-${random_string.this.result}-0"
      role_assignments = {
        rbac_storage_queue_data_reader = {
          role_definition_id_or_name = "Storage Queue Data Reader"
          principal_id               = data.azapi_client_config.current.object_id
        }
      }
    }
    queue1 = {
      name = "queue-${random_string.this.result}-1"
      metadata = {
        key1 = "value1"
        key2 = "value2"
      }
      role_assignments = {
        rbac_storage_queue_data_contributor = {
          role_definition_id_or_name = "Storage Queue Data Contributor"
          principal_id               = data.azapi_client_config.current.object_id
        }
      }
    }
  }
  # Module-wide retry. Applies to every AzAPI resource managed by the module
  # and every submodule unless overridden per-item.
  retry = {
    error_message_regex  = ["TooManyRequests", "ResourceNotFound", "RetryableError"]
    interval_seconds     = 5
    max_interval_seconds = 60
  }
  role_assignments = {
    role_assignment_1 = {
      role_definition_id_or_name = "Contributor"
      principal_id               = coalesce(var.msi_id, data.azapi_client_config.current.object_id)
    }
    role_assignment_2 = {
      role_definition_id_or_name = "Owner"
      principal_id               = data.azapi_client_config.current.object_id
    }
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
      role_assignments = {
        rbac_storage_share_data_reader = {
          role_definition_id_or_name = "Storage File Data SMB Share Reader"
          principal_id               = data.azapi_client_config.current.object_id
        }
      }
    }
    share1 = {
      name        = "share-${random_string.this.result}-1"
      quota       = 10
      access_tier = "Hot"
      metadata = {
        key1 = "value1"
        key2 = "value2"
      }
      role_assignments = {
        rbac_storage_share_data_contributor = {
          role_definition_id_or_name = "Storage File Data SMB Share Contributor"
          principal_id               = data.azapi_client_config.current.object_id
        }
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
      role_assignments = {
        rbac_storage_table_data_reader = {
          role_definition_id_or_name = "Storage Table Data Reader"
          principal_id               = data.azapi_client_config.current.object_id
        }
      }
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
      role_assignments = {
        rbac_storage_table_data_contributor = {
          role_definition_id_or_name = "Storage Table Data Contributor"
          principal_id               = data.azapi_client_config.current.object_id
        }
      }
    }
  }
  tags = {
    env   = "Dev"
    owner = "John Doe"
    dept  = "IT"
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

terraform {
  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.12"
    }
  }
}

# Shape of refreshed CMK state, including state produced by the AzureRM move.
resource "azapi_resource" "this" {
  location  = "eastus"
  name      = "stcmkunittest"
  parent_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-cmk-test"
  type      = "Microsoft.Storage/storageAccounts@2025-08-01"
  body = {
    kind = "StorageV2"
    sku = {
      name = "Standard_LRS"
    }
    properties = {
      encryption = {
        keySource = "Microsoft.Keyvault"
        identity = {
          userAssignedIdentity = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-cmk-test/providers/Microsoft.ManagedIdentity/userAssignedIdentities/id-cmk"
        }
        keyvaultproperties = {
          keyname     = "storage"
          keyvaulturi = "https://kv-cmk-test.vault.azure.net/"
          keyversion  = "version1"
        }
        services                        = {}
        requireInfrastructureEncryption = null
      }
    }
  }
  response_export_values = []

  identity {
    type         = "UserAssigned"
    identity_ids = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-cmk-test/providers/Microsoft.ManagedIdentity/userAssignedIdentities/id-cmk"]
  }
}

output "resource_id" {
  value = azapi_resource.this.id
}

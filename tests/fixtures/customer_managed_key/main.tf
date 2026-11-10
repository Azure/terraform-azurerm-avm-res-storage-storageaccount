terraform {
  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.12"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

data "azapi_client_config" "current" {}

resource "random_string" "suffix" {
  length  = 12
  special = false
  upper   = false
}

resource "azapi_resource" "resource_group" {
  location               = "westus2"
  name                   = "rg-cmk-${random_string.suffix.result}"
  parent_id              = data.azapi_client_config.current.subscription_resource_id
  type                   = "Microsoft.Resources/resourceGroups@2025-04-01"
  response_export_values = []
}

resource "azapi_resource" "identity" {
  location               = azapi_resource.resource_group.location
  name                   = "id-cmk"
  parent_id              = azapi_resource.resource_group.id
  type                   = "Microsoft.ManagedIdentity/userAssignedIdentities@2024-11-30"
  response_export_values = ["properties.principalId"]
}

resource "azapi_resource" "vault" {
  location  = azapi_resource.resource_group.location
  name      = "kv-cmk-${random_string.suffix.result}"
  parent_id = azapi_resource.resource_group.id
  type      = "Microsoft.KeyVault/vaults@2025-05-01"
  body = {
    properties = {
      tenantId                  = data.azapi_client_config.current.tenant_id
      enablePurgeProtection     = true
      enableSoftDelete          = true
      softDeleteRetentionInDays = 7
      sku = {
        family = "A"
        name   = "standard"
      }
      accessPolicies = [{
        tenantId = data.azapi_client_config.current.tenant_id
        objectId = azapi_resource.identity.output.properties.principalId
        permissions = {
          keys = ["get", "wrapKey", "unwrapKey"]
        }
      }]
    }
  }
  response_export_values = []
}

# ARM supports key creation but not deletion; deleting the vault cleans up the key.
resource "azapi_resource_action" "key" {
  method      = "PUT"
  resource_id = "${azapi_resource.vault.id}/keys/storage"
  type        = "Microsoft.KeyVault/vaults/keys@2025-05-01"
  body = {
    properties = {
      kty     = "RSA"
      keySize = 2048
      keyOps  = ["wrapKey", "unwrapKey"]
    }
  }
  response_export_values = []
}

output "location" {
  value = azapi_resource.resource_group.location
}

output "parent_id" {
  value = azapi_resource.resource_group.id
}

output "name" {
  value = "stcmk${random_string.suffix.result}"
}

output "identity_id" {
  value = azapi_resource.identity.id
}

output "customer_managed_key" {
  value = {
    key_vault_resource_id = azapi_resource.vault.id
    key_name              = "storage"
    user_assigned_identity = {
      resource_id = azapi_resource.identity.id
    }
  }

  depends_on = [azapi_resource_action.key]
}

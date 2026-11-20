terraform {
  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.12"
    }
  }
}

data "azapi_resource" "account" {
  resource_id            = var.resource_id
  type                   = "Microsoft.Storage/storageAccounts@2025-08-01"
  response_export_values = ["properties.encryption", "tags"]
}

output "encryption" {
  value = data.azapi_resource.account.output.properties.encryption
}

output "tags" {
  value = data.azapi_resource.account.output.tags
}

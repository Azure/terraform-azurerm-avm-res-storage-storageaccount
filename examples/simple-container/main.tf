terraform {
  required_version = ">= 1.3.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.7.0, < 4.0.0"
    }
  }
}

provider "azurerm" {
  features {}
  skip_provider_registration = true
  storage_use_azuread        = true
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

# This is the module call
module "storage_account" {
  source = "../../"
  # source             = "Azure/avm-<res/ptn>-<name>/azurerm"
  name                = module.naming.storage_account.name_unique
  resource_group_name = azurerm_resource_group.this.name

  storage_account_account_replication_type = "LRS"
  storage_account_account_tier             = "Standard"

  storage_container = {
    blob_container = {
      name = module.naming.storage_container.name_unique
    }
  }
}

# illustrate what the outputs look like
output "storage_container" {
  value = module.storage_account.storage_container
}

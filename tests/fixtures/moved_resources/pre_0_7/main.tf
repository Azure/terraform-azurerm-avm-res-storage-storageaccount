terraform {
  required_providers {
    azapi = {
      source = "Azure/azapi"
    }
    random = {
      source = "hashicorp/random"
    }
  }
}

module "storage" {
  source = "./storage"
}

output "resource_ids" {
  value = module.storage.resource_ids
}

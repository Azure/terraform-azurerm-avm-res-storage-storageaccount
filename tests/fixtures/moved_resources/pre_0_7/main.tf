terraform {
  required_providers {
    # tflint-ignore: terraform_unused_required_providers
    azapi = {
      source = "Azure/azapi"
    }
  }
}

module "storage" {
  source = "./storage"
}

output "resource_ids" {
  value = module.storage.resource_ids
}

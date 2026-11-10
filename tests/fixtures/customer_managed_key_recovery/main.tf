terraform {
  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.12"
    }
  }
}

data "azapi_resource_action" "remaining_resources" {
  action      = "resources"
  method      = "GET"
  resource_id = "/subscriptions/7f2966f6-23b7-4b11-94c3-ae8452328dc3/resourceGroups/rg-cmk-04lqcp0d894x"
  type        = "Microsoft.Resources/resourceGroups@2021-04-01"
  response_export_values = {
    ids = "value[].id"
  }
}

# The failed run's randomized group must contain only its own fixture resources.
resource "azapi_resource_action" "cleanup" {
  method                 = "DELETE"
  resource_id            = "/subscriptions/7f2966f6-23b7-4b11-94c3-ae8452328dc3/resourceGroups/rg-cmk-04lqcp0d894x"
  type                   = "Microsoft.Resources/resourceGroups@2025-04-01"
  ignore_not_found       = true
  response_export_values = []

  lifecycle {
    precondition {
      condition = alltrue([
        for id in data.azapi_resource_action.remaining_resources.output.ids : contains([
          "/subscriptions/7f2966f6-23b7-4b11-94c3-ae8452328dc3/resourcegroups/rg-cmk-04lqcp0d894x/providers/microsoft.managedidentity/userassignedidentities/id-cmk",
          "/subscriptions/7f2966f6-23b7-4b11-94c3-ae8452328dc3/resourcegroups/rg-cmk-04lqcp0d894x/providers/microsoft.keyvault/vaults/kv-cmk-04lqcp0d894x",
          "/subscriptions/7f2966f6-23b7-4b11-94c3-ae8452328dc3/resourcegroups/rg-cmk-04lqcp0d894x/providers/microsoft.storage/storageaccounts/stcmk04lqcp0d894x",
        ], lower(id))
      ])
      error_message = "Recovery is forbidden because the group contains resources not owned by CI run 42746740980."
    }
  }
}

data "azapi_resource_list" "resource_groups" {
  parent_id = "/subscriptions/7f2966f6-23b7-4b11-94c3-ae8452328dc3"
  type      = "Microsoft.Resources/resourceGroups@2025-04-01"
  response_export_values = {
    names = "value[].name"
  }

  depends_on = [azapi_resource_action.cleanup]
}

output "removed" {
  value = !contains(data.azapi_resource_list.resource_groups.output.names, "rg-cmk-04lqcp0d894x")

  precondition {
    condition     = !contains(data.azapi_resource_list.resource_groups.output.names, "rg-cmk-04lqcp0d894x")
    error_message = "The failed run's resource group must be absent before integration tests can proceed."
  }
}

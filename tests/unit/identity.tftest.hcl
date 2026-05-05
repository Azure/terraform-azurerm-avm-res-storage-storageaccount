# Unit tests for managed identity composition.
mock_provider "azapi" {}
mock_provider "modtm" {}
mock_provider "random" {}

variables {
  location                 = "eastus"
  name                     = "stunittest001"
  parent_id                = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-unit-test"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

run "no_identity" {
  command = plan

  variables {
    managed_identities = {
      system_assigned            = false
      user_assigned_resource_ids = []
    }
  }

  assert {
    condition     = length(azapi_resource.this.identity) == 0
    error_message = "Expected no identity block when managed_identities is empty"
  }
}

run "system_assigned" {
  command = plan

  variables {
    managed_identities = {
      system_assigned            = true
      user_assigned_resource_ids = []
    }
  }

  assert {
    condition     = azapi_resource.this.identity[0].type == "SystemAssigned"
    error_message = "Expected SystemAssigned identity type"
  }

  assert {
    condition     = length(azapi_resource.this.identity[0].identity_ids) == 0
    error_message = "Expected empty identity_ids list when only system_assigned"
  }
}

run "user_assigned_only" {
  command = plan

  variables {
    managed_identities = {
      system_assigned            = false
      user_assigned_resource_ids = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-uami/providers/Microsoft.ManagedIdentity/userAssignedIdentities/uami1"]
    }
  }

  assert {
    condition     = azapi_resource.this.identity[0].type == "UserAssigned"
    error_message = "Expected UserAssigned identity type"
  }

  assert {
    condition     = length(azapi_resource.this.identity[0].identity_ids) == 1
    error_message = "Expected 1 user-assigned identity"
  }
}

run "system_and_user_assigned" {
  command = plan

  variables {
    managed_identities = {
      system_assigned            = true
      user_assigned_resource_ids = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-uami/providers/Microsoft.ManagedIdentity/userAssignedIdentities/uami1"]
    }
  }

  assert {
    condition     = azapi_resource.this.identity[0].type == "SystemAssigned, UserAssigned"
    error_message = "Expected SystemAssigned, UserAssigned identity type"
  }

  assert {
    condition     = length(azapi_resource.this.identity[0].identity_ids) == 1
    error_message = "Expected 1 user-assigned identity"
  }
}

# Unit tests for the Smart access tier preconditions.
mock_provider "azapi" {}
mock_provider "modtm" {}
mock_provider "random" {}

variables {
  location  = "eastus"
  name      = "stunittest001"
  parent_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-unit-test"
}

# Smart with a zone-redundant SKU (default Standard_ZRS), StorageV2 and the
# default storage account api-version must plan cleanly.
run "smart_valid" {
  command = plan

  variables {
    access_tier = "Smart"
  }
}

# Schema-supported api-versions above 2025-08-01 are accepted.
run "smart_valid_newer_api_version" {
  command = plan

  variables {
    access_tier = "Smart"
    resource_types = {
      storage_account = "Microsoft.Storage/storageAccounts@2026-04-01"
    }
  }
}

# Smart with an api-version older than 2025-08-01 must fail the precondition.
# This is the case that previously slipped through because of the string `>=`.
run "smart_api_too_old" {
  command = plan

  variables {
    access_tier = "Smart"
    resource_types = {
      storage_account = "Microsoft.Storage/storageAccounts@2025-06-01"
    }
  }

  expect_failures = [
    azapi_resource.this,
  ]
}

# Smart on a non zone-redundant SKU must fail the precondition.
run "smart_invalid_sku" {
  command = plan

  variables {
    access_tier      = "Smart"
    account_sku_name = "Standard_LRS"
    resource_types = {
      storage_account = "Microsoft.Storage/storageAccounts@2025-08-01"
    }
  }

  expect_failures = [
    azapi_resource.this,
  ]
}

# Non-Smart tiers are unaffected: default api-version and default SKU still plan.
run "hot_unaffected" {
  command = plan

  variables {
    access_tier = "Hot"
  }
}

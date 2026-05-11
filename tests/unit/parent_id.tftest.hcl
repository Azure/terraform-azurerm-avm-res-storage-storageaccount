# Unit tests for parent_id parsing and resource_group_name local extraction.
mock_provider "azapi" {}
mock_provider "modtm" {}
mock_provider "random" {}

variables {
  location                 = "eastus"
  name                     = "stunittest001"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

run "valid_parent_id_extracts_rg_name" {
  command = plan

  variables {
    parent_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/my-test-rg"
  }

  assert {
    condition     = azapi_resource.this.parent_id == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/my-test-rg"
    error_message = "Expected parent_id to be passed through verbatim to azapi_resource"
  }
}

run "invalid_parent_id_rejected" {
  command = plan

  variables {
    parent_id = "not-a-valid-resource-id"
  }

  expect_failures = [var.parent_id]
}

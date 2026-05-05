# Unit tests for sku_name composition (account_tier + account_replication_type
# with optional V2 suffix when provisioned_billing_model_version == "V2").
mock_provider "azapi" {}
mock_provider "modtm" {}
mock_provider "random" {}

variables {
  location  = "eastus"
  name      = "stunittest001"
  parent_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-unit-test"
}

run "v1_standard_lrs" {
  command = plan

  variables {
    account_tier             = "Standard"
    account_replication_type = "LRS"
  }

  assert {
    condition     = azapi_resource.this.body.sku.name == "Standard_LRS"
    error_message = "Expected sku.name == Standard_LRS"
  }
}

run "v1_premium_zrs" {
  command = plan

  variables {
    account_tier             = "Premium"
    account_replication_type = "ZRS"
    account_kind             = "BlockBlobStorage"
  }

  assert {
    condition     = azapi_resource.this.body.sku.name == "Premium_ZRS"
    error_message = "Expected sku.name == Premium_ZRS"
  }
}

run "v2_standard_lrs" {
  command = plan

  variables {
    account_tier                      = "Standard"
    account_replication_type          = "LRS"
    provisioned_billing_model_version = "V2"
  }

  assert {
    condition     = azapi_resource.this.body.sku.name == "StandardV2_LRS"
    error_message = "Expected sku.name == StandardV2_LRS when provisioned_billing_model_version == V2"
  }
}

run "v2_premium_zrs" {
  command = plan

  variables {
    account_tier                      = "Premium"
    account_replication_type          = "ZRS"
    account_kind                      = "BlockBlobStorage"
    provisioned_billing_model_version = "V2"
  }

  assert {
    condition     = azapi_resource.this.body.sku.name == "PremiumV2_ZRS"
    error_message = "Expected sku.name == PremiumV2_ZRS when provisioned_billing_model_version == V2"
  }
}

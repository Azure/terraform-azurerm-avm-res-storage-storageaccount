# Unit tests for static-website wiring on the root module.
#
# Regression cover for #363: the static-website patch must not reuse the
# `blob_service` API version. `properties.staticWebsite` was only added to the
# blob service schema in 2025-08-01, and earlier versions silently drop it.
mock_provider "azapi" {}
mock_provider "modtm" {}
mock_provider "random" {}

variables {
  location                 = "eastus"
  name                     = "stunittest001"
  parent_id                = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-unit-test"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  static_website = {
    this = {
      error_404_document = "404.html"
      index_document     = "index.html"
    }
  }
}

run "static_website_api_version_default_is_supported" {
  command = plan

  assert {
    condition     = tonumber(replace(regex("^\\d{4}-\\d{2}-\\d{2}", split("@", var.resource_types.static_website)[1]), "-", "")) >= 20250801
    error_message = "resource_types.static_website must default to API version 2025-08-01 or later, otherwise properties.staticWebsite is silently discarded"
  }
}

run "static_website_module_instantiated" {
  command = plan

  assert {
    condition     = length(module.static_website) == 1
    error_message = "Expected one static_website submodule instance"
  }
}

run "static_website_omitted_when_null" {
  command = plan

  variables {
    static_website = null
  }

  assert {
    condition     = length(module.static_website) == 0
    error_message = "Expected no static_website submodule instances when var.static_website is null"
  }
}

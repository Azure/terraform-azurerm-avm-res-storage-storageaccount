# Unit tests for the static_website submodule.
#
# Regression cover for #363: `properties.staticWebsite` was only added to the
# blob service schema in API version 2025-08-01. On earlier versions AzAPI
# silently drops the property, so the request succeeds while the static website
# stays disabled and every subsequent plan shows the same drift.
mock_provider "azapi" {}

variables {
  storage_account_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-unit-test/providers/Microsoft.Storage/storageAccounts/stunittest001"
  error_404_document = "404.html"
  index_document     = "index.html"
}

run "api_version_supports_static_website" {
  command = plan

  assert {
    condition     = tonumber(replace(regex("^\\d{4}-\\d{2}-\\d{2}", split("@", azapi_update_resource.this.type)[1]), "-", "")) >= 20250801
    error_message = "The default resource_type must use API version 2025-08-01 or later, otherwise properties.staticWebsite is silently discarded and the static website is never enabled"
  }
}

run "unsupported_api_version_is_rejected" {
  command = plan

  variables {
    resource_type = "Microsoft.Storage/storageAccounts/blobServices@2025-06-01"
  }

  expect_failures = [var.resource_type]
}

run "body_maps_inputs_to_arm_properties" {
  command = plan

  assert {
    condition     = azapi_update_resource.this.body.properties.staticWebsite.enabled == true
    error_message = "Expected staticWebsite.enabled to be true"
  }

  assert {
    condition     = azapi_update_resource.this.body.properties.staticWebsite.indexDocument == "index.html"
    error_message = "Expected index_document to map to staticWebsite.indexDocument"
  }

  assert {
    condition     = azapi_update_resource.this.body.properties.staticWebsite.errorDocument404Path == "404.html"
    error_message = "Expected error_404_document to map to staticWebsite.errorDocument404Path"
  }
}

run "patch_targets_blob_service_default" {
  command = plan

  assert {
    condition     = azapi_update_resource.this.resource_id == "${var.storage_account_id}/blobServices/default"
    error_message = "Expected the patch to target the blobServices/default sub-resource"
  }
}

run "tracing_headers_omitted_by_default" {
  command = plan

  assert {
    condition     = azapi_update_resource.this.update_headers == null && azapi_update_resource.this.read_headers == null
    error_message = "Expected no custom headers when tracing_tags_header is null"
  }
}

run "tracing_headers_applied" {
  command = plan

  variables {
    tracing_tags_header = "avm-test-header"
  }

  assert {
    condition     = azapi_update_resource.this.update_headers["User-Agent"] == "avm-test-header"
    error_message = "Expected tracing_tags_header to be sent as the User-Agent update header"
  }

  assert {
    condition     = azapi_update_resource.this.read_headers["User-Agent"] == "avm-test-header"
    error_message = "Expected tracing_tags_header to be sent as the User-Agent read header"
  }
}

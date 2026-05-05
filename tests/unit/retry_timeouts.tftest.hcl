# Unit tests for retry attribute and timeouts dynamic block on the root
# storage account azapi_resource.
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

run "retry_null_omitted" {
  command = plan

  variables {
    retry = null
  }

  assert {
    condition     = azapi_resource.this.retry == null
    error_message = "Expected retry to be null when var.retry is null"
  }
}

run "retry_propagated" {
  command = plan

  variables {
    retry = {
      error_message_regex  = ["TooManyRequests", "RetryableError"]
      interval_seconds     = 5
      max_interval_seconds = 60
    }
  }

  assert {
    condition     = azapi_resource.this.retry.interval_seconds == 5
    error_message = "Expected retry.interval_seconds == 5"
  }

  assert {
    condition     = azapi_resource.this.retry.max_interval_seconds == 60
    error_message = "Expected retry.max_interval_seconds == 60"
  }

  assert {
    condition     = length(azapi_resource.this.retry.error_message_regex) == 2
    error_message = "Expected 2 retry regex patterns"
  }
}

run "timeouts_null_omitted" {
  command = plan

  variables {
    timeouts = null
  }

  assert {
    condition     = azapi_resource.this.timeouts == null
    error_message = "Expected timeouts block omitted when var.timeouts is null"
  }
}

run "timeouts_emitted" {
  command = plan

  variables {
    timeouts = {
      create = "60m"
      read   = "5m"
      update = "60m"
      delete = "60m"
    }
  }

  assert {
    condition     = azapi_resource.this.timeouts.create == "60m"
    error_message = "Expected timeouts.create == 60m"
  }

  assert {
    condition     = azapi_resource.this.timeouts.delete == "60m"
    error_message = "Expected timeouts.delete == 60m"
  }
}

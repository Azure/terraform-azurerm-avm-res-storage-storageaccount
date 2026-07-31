# Unit tests for Storage service diagnostic metric normalization.
mock_provider "azapi" {}
mock_provider "modtm" {}
mock_provider "random" {}

variables {
  location                 = "eastus"
  name                     = "stunittest001"
  parent_id                = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-unit-test"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  diagnostic_settings_blob = {
    normalized = {
      name                  = "blob-diagnostic-setting"
      workspace_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-unit-test/providers/Microsoft.OperationalInsights/workspaces/law-unit-test"
      metrics = [{
        category = "AllMetrics"
        enabled  = false
        retention_policy = {
          days    = 7
          enabled = true
        }
      }]
    }
  }

  diagnostic_settings_file = {
    normalized = {
      name                  = "file-diagnostic-setting"
      workspace_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-unit-test/providers/Microsoft.OperationalInsights/workspaces/law-unit-test"
      metrics = [{
        category = "AllMetrics"
      }]
    }
  }

  diagnostic_settings_queue = {
    normalized = {
      name                  = "queue-diagnostic-setting"
      workspace_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-unit-test/providers/Microsoft.OperationalInsights/workspaces/law-unit-test"
      metrics = [
        {
          category = "AllMetrics"
          enabled  = false
          retention_policy = {
            days    = 30
            enabled = true
          }
        },
        {
          category = "Capacity"
          enabled  = true
          retention_policy = {
            days    = 5
            enabled = false
          }
        },
        {
          category = "CustomMetric"
          enabled  = false
        }
      ]
    }
  }

  diagnostic_settings_storage_account = {
    unchanged = {
      name                  = "account-diagnostic-setting"
      workspace_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-unit-test/providers/Microsoft.OperationalInsights/workspaces/law-unit-test"
      metrics = [{
        category = "AllMetrics"
      }]
    }
  }

  diagnostic_settings_table = {
    normalized = {
      name                  = "table-all-metrics-diagnostic-setting"
      workspace_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-unit-test/providers/Microsoft.OperationalInsights/workspaces/law-unit-test"
      metrics = [{
        category = "AllMetrics"
      }]
    }
    passthrough = {
      name                  = "table-diagnostic-setting"
      workspace_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-unit-test/providers/Microsoft.OperationalInsights/workspaces/law-unit-test"
      metrics = [{
        category = "Transaction"
        enabled  = false
        retention_policy = {
          days    = 14
          enabled = true
        }
      }]
    }
  }
}

run "normalize_storage_service_metrics" {
  command = plan

  assert {
    condition = length(module.diagnostic_setting_blob.resources["normalized"].body.properties.metrics) == 2 && toset([
      for metric in module.diagnostic_setting_blob.resources["normalized"].body.properties.metrics : metric.category
    ]) == toset(["Capacity", "Transaction"])
    error_message = "Blob AllMetrics must normalize to Capacity and Transaction."
  }

  assert {
    condition = alltrue([
      for metric in module.diagnostic_setting_blob.resources["normalized"].body.properties.metrics :
      metric.enabled == false && metric.retentionPolicy.days == 7 && metric.retentionPolicy.enabled == true
    ])
    error_message = "Expanded Blob metrics must preserve enabled and retention_policy."
  }

  assert {
    condition = length(module.diagnostic_setting_file.resources["normalized"].body.properties.metrics) == 3 && toset([
      for metric in module.diagnostic_setting_file.resources["normalized"].body.properties.metrics : metric.category
    ]) == toset(["Capacity", "SLI", "Transaction"])
    error_message = "File AllMetrics must normalize to all supported metric categories, including SLI."
  }

  assert {
    condition = alltrue([
      for metric in module.diagnostic_setting_file.resources["normalized"].body.properties.metrics :
      metric.enabled == true && metric.retentionPolicy.days == 0 && metric.retentionPolicy.enabled == false
    ])
    error_message = "Expanded File metrics must preserve the default enabled and retention_policy values."
  }

  assert {
    condition = length(module.diagnostic_setting_queue.resources["normalized"].body.properties.metrics) == 3 && toset([
      for metric in module.diagnostic_setting_queue.resources["normalized"].body.properties.metrics : metric.category
    ]) == toset(["Capacity", "CustomMetric", "Transaction"])
    error_message = "Queue normalization must deduplicate explicit concrete categories and preserve custom categories."
  }

  assert {
    condition = one([
      for metric in module.diagnostic_setting_queue.resources["normalized"].body.properties.metrics : metric
      if metric.category == "Capacity"
      ]).enabled == true && one([
      for metric in module.diagnostic_setting_queue.resources["normalized"].body.properties.metrics : metric
      if metric.category == "Capacity"
    ]).retentionPolicy.days == 5
    error_message = "An explicit Queue metric must take precedence over the category generated from AllMetrics."
  }

  assert {
    condition = one([
      for metric in module.diagnostic_setting_queue.resources["normalized"].body.properties.metrics : metric
      if metric.category == "Transaction"
      ]).enabled == false && one([
      for metric in module.diagnostic_setting_queue.resources["normalized"].body.properties.metrics : metric
      if metric.category == "Transaction"
    ]).retentionPolicy.days == 30
    error_message = "A generated Queue metric must preserve the AllMetrics properties."
  }

  assert {
    condition = one([
      for metric in module.diagnostic_setting_queue.resources["normalized"].body.properties.metrics : metric
      if metric.category == "CustomMetric"
    ]).enabled == false
    error_message = "Non-AllMetrics Queue entries must pass through unchanged."
  }

  assert {
    condition = length(module.diagnostic_setting_table.resources["normalized"].body.properties.metrics) == 2 && toset([
      for metric in module.diagnostic_setting_table.resources["normalized"].body.properties.metrics : metric.category
    ]) == toset(["Capacity", "Transaction"])
    error_message = "Table AllMetrics must normalize to Capacity and Transaction."
  }

  assert {
    condition = one(module.diagnostic_setting_table.resources["passthrough"].body.properties.metrics).category == "Transaction" && one(
      module.diagnostic_setting_table.resources["passthrough"].body.properties.metrics
    ).retentionPolicy.days == 14
    error_message = "Concrete Table metrics and their properties must pass through unchanged."
  }

  assert {
    condition = one(
      module.diagnostic_setting_storage_account.resources["unchanged"].body.properties.metrics
    ).category == "AllMetrics"
    error_message = "Storage-account-scope AllMetrics must not be normalized."
  }
}

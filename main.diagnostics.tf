
# Enable Diagnostic Settings for Storage account
resource "azurerm_monitor_diagnostic_setting" "storage_account" {
  for_each = var.diagnostic_settings_storage_account == null ? {} : var.diagnostic_settings_storage_account

  name                       = each.value.name
  target_resource_id         = azurerm_storage_account.this.id
  log_analytics_workspace_id = each.value.log_analytics_workspace_id

  dynamic "metric" {
    for_each = each.value.metric_categories
    content {
      category = metric.value
    }
  }
}
# Enable Diagnostic Settings for Blob
resource "azurerm_monitor_diagnostic_setting" "blob" {
  for_each = var.diagnostic_settings_blob == null ? {} : var.diagnostic_settings_blob

  name                       = each.value.name
  target_resource_id         = "${azurerm_storage_account.this.id}/blobServices/default/"
  log_analytics_workspace_id = each.value.log_analytics_workspace_id

  dynamic "enabled_log" {
    for_each = each.value.log_categories
    content {
      category_group = enabled_log.value
    }
  }
  dynamic "metric" {
    for_each = each.value.metric_categories
    content {
      category = metric.value
    }
  }
}

# Enable Diagnostic Settings for Queue
resource "azurerm_monitor_diagnostic_setting" "queue" {
  for_each = var.diagnostic_settings_queue == null ? {} : var.diagnostic_settings_queue

  name                       = each.value.name
  target_resource_id         = "${azurerm_storage_account.this.id}/queueServices/default/"
  log_analytics_workspace_id = each.value.log_analytics_workspace_id

  dynamic "enabled_log" {
    for_each = each.value.log_categories
    content {
      category_group = enabled_log.value
    }
  }
  dynamic "metric" {
    for_each = each.value.metric_categories
    content {
      category = metric.value
    }
  }
}
# Enable Diagnostic Settings for Table
resource "azurerm_monitor_diagnostic_setting" "table" {
  for_each = var.diagnostic_settings_table == null ? {} : var.diagnostic_settings_table

  name                       = each.value.name
  target_resource_id         = "${azurerm_storage_account.this.id}/tableServices/default/"
  log_analytics_workspace_id = each.value.log_analytics_workspace_id

  dynamic "enabled_log" {
    for_each = each.value.log_categories
    content {
      category_group = enabled_log.value
    }
  }
  dynamic "metric" {
    for_each = each.value.metric_categories
    content {
      category = metric.value
    }
  }
}
# Enable Diagnostic Settings for Azure Files
resource "azurerm_monitor_diagnostic_setting" "azure_file" {
  for_each = var.diagnostic_settings_file == null ? {} : var.diagnostic_settings_file

  name                       = each.value.name
  target_resource_id         = "${azurerm_storage_account.this.id}/fileServices/default/"
  log_analytics_workspace_id = each.value.log_analytics_workspace_id

  dynamic "enabled_log" {
    for_each = each.value.log_categories
    content {
      category_group = enabled_log.value
    }
  }
  dynamic "metric" {
    for_each = each.value.metric_categories
    content {
      category = metric.value
    }
  }
}




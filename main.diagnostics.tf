module "diagnostic_setting_storage_account" {
  source   = "./modules/diagnostic_setting"
  for_each = var.diagnostic_settings_storage_account

  target_resource_id                       = azapi_resource.this.id
  name                                     = each.value.name != null ? each.value.name : "diag-${each.key}"
  metric_categories                        = each.value.metric_categories
  log_analytics_destination_type           = each.value.log_analytics_destination_type
  workspace_resource_id                    = each.value.workspace_resource_id
  storage_account_resource_id              = each.value.storage_account_resource_id
  event_hub_authorization_rule_resource_id = each.value.event_hub_authorization_rule_resource_id
  event_hub_name                           = each.value.event_hub_name
  marketplace_partner_resource_id          = each.value.marketplace_partner_resource_id

  retry               = var.retry
  timeouts            = var.timeouts
  tracing_tags_header = var.enable_telemetry ? local.avm_azapi_header : null
}

module "diagnostic_setting_blob" {
  source   = "./modules/diagnostic_setting"
  for_each = var.diagnostic_settings_blob

  target_resource_id                       = "${azapi_resource.this.id}/blobServices/default"
  name                                     = each.value.name != null ? each.value.name : "diag-${each.key}"
  log_categories                           = each.value.log_categories
  log_groups                               = each.value.log_groups
  metric_categories                        = each.value.metric_categories
  log_analytics_destination_type           = each.value.log_analytics_destination_type
  workspace_resource_id                    = each.value.workspace_resource_id
  storage_account_resource_id              = each.value.storage_account_resource_id
  event_hub_authorization_rule_resource_id = each.value.event_hub_authorization_rule_resource_id
  event_hub_name                           = each.value.event_hub_name
  marketplace_partner_resource_id          = each.value.marketplace_partner_resource_id

  retry               = var.retry
  timeouts            = var.timeouts
  tracing_tags_header = var.enable_telemetry ? local.avm_azapi_header : null
}

module "diagnostic_setting_queue" {
  source   = "./modules/diagnostic_setting"
  for_each = var.diagnostic_settings_queue

  target_resource_id                       = "${azapi_resource.this.id}/queueServices/default"
  name                                     = each.value.name != null ? each.value.name : "diag-${each.key}"
  log_categories                           = each.value.log_categories
  log_groups                               = each.value.log_groups
  metric_categories                        = each.value.metric_categories
  log_analytics_destination_type           = each.value.log_analytics_destination_type
  workspace_resource_id                    = each.value.workspace_resource_id
  storage_account_resource_id              = each.value.storage_account_resource_id
  event_hub_authorization_rule_resource_id = each.value.event_hub_authorization_rule_resource_id
  event_hub_name                           = each.value.event_hub_name
  marketplace_partner_resource_id          = each.value.marketplace_partner_resource_id

  retry               = var.retry
  timeouts            = var.timeouts
  tracing_tags_header = var.enable_telemetry ? local.avm_azapi_header : null
}

module "diagnostic_setting_table" {
  source   = "./modules/diagnostic_setting"
  for_each = var.diagnostic_settings_table

  target_resource_id                       = "${azapi_resource.this.id}/tableServices/default"
  name                                     = each.value.name != null ? each.value.name : "diag-${each.key}"
  log_categories                           = each.value.log_categories
  log_groups                               = each.value.log_groups
  metric_categories                        = each.value.metric_categories
  log_analytics_destination_type           = each.value.log_analytics_destination_type
  workspace_resource_id                    = each.value.workspace_resource_id
  storage_account_resource_id              = each.value.storage_account_resource_id
  event_hub_authorization_rule_resource_id = each.value.event_hub_authorization_rule_resource_id
  event_hub_name                           = each.value.event_hub_name
  marketplace_partner_resource_id          = each.value.marketplace_partner_resource_id

  retry               = var.retry
  timeouts            = var.timeouts
  tracing_tags_header = var.enable_telemetry ? local.avm_azapi_header : null
}

module "diagnostic_setting_file" {
  source   = "./modules/diagnostic_setting"
  for_each = var.diagnostic_settings_file

  target_resource_id                       = "${azapi_resource.this.id}/fileServices/default"
  name                                     = each.value.name != null ? each.value.name : "diag-${each.key}"
  log_categories                           = each.value.log_categories
  log_groups                               = each.value.log_groups
  metric_categories                        = each.value.metric_categories
  log_analytics_destination_type           = each.value.log_analytics_destination_type
  workspace_resource_id                    = each.value.workspace_resource_id
  storage_account_resource_id              = each.value.storage_account_resource_id
  event_hub_authorization_rule_resource_id = each.value.event_hub_authorization_rule_resource_id
  event_hub_name                           = each.value.event_hub_name
  marketplace_partner_resource_id          = each.value.marketplace_partner_resource_id

  retry               = var.retry
  timeouts            = var.timeouts
  tracing_tags_header = var.enable_telemetry ? local.avm_azapi_header : null
}

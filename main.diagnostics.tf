module "diagnostic_setting_storage_account" {
  source   = "./modules/diagnostic_setting"
  for_each = var.diagnostic_settings_storage_account

  name                                     = each.value.name != null ? each.value.name : "diag-${each.key}"
  target_resource_id                       = azapi_resource.this.id
  event_hub_authorization_rule_resource_id = each.value.event_hub_authorization_rule_resource_id
  event_hub_name                           = each.value.event_hub_name
  log_analytics_destination_type           = each.value.log_analytics_destination_type
  marketplace_partner_resource_id          = each.value.marketplace_partner_resource_id
  metric_categories                        = each.value.metric_categories
  retry                                    = var.retry
  storage_account_resource_id              = each.value.storage_account_resource_id
  timeouts                                 = var.timeouts
  tracing_tags_header                      = var.enable_telemetry ? local.avm_azapi_header : null
  workspace_resource_id                    = each.value.workspace_resource_id
}

module "diagnostic_setting_blob" {
  source   = "./modules/diagnostic_setting"
  for_each = var.diagnostic_settings_blob

  name                                     = each.value.name != null ? each.value.name : "diag-${each.key}"
  target_resource_id                       = "${azapi_resource.this.id}/blobServices/default"
  event_hub_authorization_rule_resource_id = each.value.event_hub_authorization_rule_resource_id
  event_hub_name                           = each.value.event_hub_name
  log_analytics_destination_type           = each.value.log_analytics_destination_type
  log_categories                           = each.value.log_categories
  log_groups                               = each.value.log_groups
  marketplace_partner_resource_id          = each.value.marketplace_partner_resource_id
  metric_categories                        = each.value.metric_categories
  retry                                    = var.retry
  storage_account_resource_id              = each.value.storage_account_resource_id
  timeouts                                 = var.timeouts
  tracing_tags_header                      = var.enable_telemetry ? local.avm_azapi_header : null
  workspace_resource_id                    = each.value.workspace_resource_id
}

module "diagnostic_setting_queue" {
  source   = "./modules/diagnostic_setting"
  for_each = var.diagnostic_settings_queue

  name                                     = each.value.name != null ? each.value.name : "diag-${each.key}"
  target_resource_id                       = "${azapi_resource.this.id}/queueServices/default"
  event_hub_authorization_rule_resource_id = each.value.event_hub_authorization_rule_resource_id
  event_hub_name                           = each.value.event_hub_name
  log_analytics_destination_type           = each.value.log_analytics_destination_type
  log_categories                           = each.value.log_categories
  log_groups                               = each.value.log_groups
  marketplace_partner_resource_id          = each.value.marketplace_partner_resource_id
  metric_categories                        = each.value.metric_categories
  retry                                    = var.retry
  storage_account_resource_id              = each.value.storage_account_resource_id
  timeouts                                 = var.timeouts
  tracing_tags_header                      = var.enable_telemetry ? local.avm_azapi_header : null
  workspace_resource_id                    = each.value.workspace_resource_id
}

module "diagnostic_setting_table" {
  source   = "./modules/diagnostic_setting"
  for_each = var.diagnostic_settings_table

  name                                     = each.value.name != null ? each.value.name : "diag-${each.key}"
  target_resource_id                       = "${azapi_resource.this.id}/tableServices/default"
  event_hub_authorization_rule_resource_id = each.value.event_hub_authorization_rule_resource_id
  event_hub_name                           = each.value.event_hub_name
  log_analytics_destination_type           = each.value.log_analytics_destination_type
  log_categories                           = each.value.log_categories
  log_groups                               = each.value.log_groups
  marketplace_partner_resource_id          = each.value.marketplace_partner_resource_id
  metric_categories                        = each.value.metric_categories
  retry                                    = var.retry
  storage_account_resource_id              = each.value.storage_account_resource_id
  timeouts                                 = var.timeouts
  tracing_tags_header                      = var.enable_telemetry ? local.avm_azapi_header : null
  workspace_resource_id                    = each.value.workspace_resource_id
}

module "diagnostic_setting_file" {
  source   = "./modules/diagnostic_setting"
  for_each = var.diagnostic_settings_file

  name                                     = each.value.name != null ? each.value.name : "diag-${each.key}"
  target_resource_id                       = "${azapi_resource.this.id}/fileServices/default"
  event_hub_authorization_rule_resource_id = each.value.event_hub_authorization_rule_resource_id
  event_hub_name                           = each.value.event_hub_name
  log_analytics_destination_type           = each.value.log_analytics_destination_type
  log_categories                           = each.value.log_categories
  log_groups                               = each.value.log_groups
  marketplace_partner_resource_id          = each.value.marketplace_partner_resource_id
  metric_categories                        = each.value.metric_categories
  retry                                    = var.retry
  storage_account_resource_id              = each.value.storage_account_resource_id
  timeouts                                 = var.timeouts
  tracing_tags_header                      = var.enable_telemetry ? local.avm_azapi_header : null
  workspace_resource_id                    = each.value.workspace_resource_id
}

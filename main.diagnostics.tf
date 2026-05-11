module "diagnostic_setting_storage_account" {
  source = "./modules/diagnostic_setting"

  parent_id           = azapi_resource.this.id
  diagnostic_settings = var.diagnostic_settings_storage_account
  enable_telemetry    = var.enable_telemetry
  retry               = var.retry
  timeouts            = var.timeouts
  tracing_tags_header = var.enable_telemetry ? local.avm_azapi_header : null
}

module "diagnostic_setting_blob" {
  source = "./modules/diagnostic_setting"

  parent_id           = "${azapi_resource.this.id}/blobServices/default"
  diagnostic_settings = var.diagnostic_settings_blob
  enable_telemetry    = var.enable_telemetry
  retry               = var.retry
  timeouts            = var.timeouts
  tracing_tags_header = var.enable_telemetry ? local.avm_azapi_header : null
}

module "diagnostic_setting_queue" {
  source = "./modules/diagnostic_setting"

  parent_id           = "${azapi_resource.this.id}/queueServices/default"
  diagnostic_settings = var.diagnostic_settings_queue
  enable_telemetry    = var.enable_telemetry
  retry               = var.retry
  timeouts            = var.timeouts
  tracing_tags_header = var.enable_telemetry ? local.avm_azapi_header : null
}

module "diagnostic_setting_table" {
  source = "./modules/diagnostic_setting"

  parent_id           = "${azapi_resource.this.id}/tableServices/default"
  diagnostic_settings = var.diagnostic_settings_table
  enable_telemetry    = var.enable_telemetry
  retry               = var.retry
  timeouts            = var.timeouts
  tracing_tags_header = var.enable_telemetry ? local.avm_azapi_header : null
}

module "diagnostic_setting_file" {
  source = "./modules/diagnostic_setting"

  parent_id           = "${azapi_resource.this.id}/fileServices/default"
  diagnostic_settings = var.diagnostic_settings_file
  enable_telemetry    = var.enable_telemetry
  retry               = var.retry
  timeouts            = var.timeouts
  tracing_tags_header = var.enable_telemetry ? local.avm_azapi_header : null
}

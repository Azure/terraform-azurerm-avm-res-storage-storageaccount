module "diagnostic_setting_storage_account" {
  source = "./modules/diagnostic_setting"

  parent_id           = azapi_resource.this.id
  diagnostic_settings = var.diagnostic_settings_storage_account
  enable_telemetry    = var.enable_telemetry
  retry               = var.retry
  timeouts            = var.timeouts
}

module "diagnostic_setting_blob" {
  source = "./modules/diagnostic_setting"

  parent_id           = "${azapi_resource.this.id}/blobServices/default"
  diagnostic_settings = local.storage_service_diagnostic_settings_normalized.blob
  enable_telemetry    = var.enable_telemetry
  retry               = var.retry
  timeouts            = var.timeouts
}

module "diagnostic_setting_queue" {
  source = "./modules/diagnostic_setting"

  parent_id           = "${azapi_resource.this.id}/queueServices/default"
  diagnostic_settings = local.storage_service_diagnostic_settings_normalized.queue
  enable_telemetry    = var.enable_telemetry
  retry               = var.retry
  timeouts            = var.timeouts
}

module "diagnostic_setting_table" {
  source = "./modules/diagnostic_setting"

  parent_id           = "${azapi_resource.this.id}/tableServices/default"
  diagnostic_settings = local.storage_service_diagnostic_settings_normalized.table
  enable_telemetry    = var.enable_telemetry
  retry               = var.retry
  timeouts            = var.timeouts
}

module "diagnostic_setting_file" {
  source = "./modules/diagnostic_setting"

  parent_id           = "${azapi_resource.this.id}/fileServices/default"
  diagnostic_settings = local.storage_service_diagnostic_settings_normalized.file
  enable_telemetry    = var.enable_telemetry
  retry               = var.retry
  timeouts            = var.timeouts
}

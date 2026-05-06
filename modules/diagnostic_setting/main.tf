locals {
  tracing_headers = var.tracing_tags_header == null ? null : { "User-Agent" = var.tracing_tags_header }
}

module "interfaces" {
  source  = "Azure/avm-utl-interfaces/azure"
  version = "0.6.0"

  diagnostic_settings_v2 = var.diagnostic_settings
  enable_telemetry       = var.enable_telemetry
}

resource "azapi_resource" "this" {
  for_each = module.interfaces.diagnostic_settings_azapi_v2

  name                      = each.value.name
  parent_id                 = var.parent_id
  type                      = each.value.type
  body                      = each.value.body
  create_headers            = local.tracing_headers
  delete_headers            = local.tracing_headers
  read_headers              = local.tracing_headers
  retry                     = var.retry
  schema_validation_enabled = false
  update_headers            = local.tracing_headers

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }

  lifecycle {
    ignore_changes = [body.properties.logAnalyticsDestinationType]
  }
}

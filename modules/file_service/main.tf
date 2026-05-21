resource "azapi_update_resource" "this" {
  resource_id = "${var.storage_account_id}/fileServices/default"
  type        = var.resource_type
  body = {
    properties = {
      cors = var.file_service_properties.cors_rules == null ? null : {
        corsRules = [for r in var.file_service_properties.cors_rules : {
          allowedHeaders  = r.allowed_headers
          allowedMethods  = r.allowed_methods
          allowedOrigins  = r.allowed_origins
          exposedHeaders  = r.exposed_headers
          maxAgeInSeconds = r.max_age_in_seconds
        }]
      }
      shareDeleteRetentionPolicy = var.file_service_properties.share_retention_policy == null ? null : {
        enabled = var.file_service_properties.share_retention_policy.enabled
        days    = var.file_service_properties.share_retention_policy.days
      }
      protocolSettings = var.file_service_properties.smb == null ? null : {
        smb = {
          authenticationMethods    = var.file_service_properties.smb.authentication_types == null ? null : join(";", var.file_service_properties.smb.authentication_types)
          channelEncryption        = var.file_service_properties.smb.channel_encryption_types == null ? null : join(";", var.file_service_properties.smb.channel_encryption_types)
          kerberosTicketEncryption = var.file_service_properties.smb.kerberos_ticket_encryption_type == null ? null : join(";", var.file_service_properties.smb.kerberos_ticket_encryption_type)
          multichannel = var.file_service_properties.smb.multichannel_enabled == null ? null : {
            enabled = var.file_service_properties.smb.multichannel_enabled
          }
          versions = var.file_service_properties.smb.versions == null ? null : join(";", var.file_service_properties.smb.versions)
        }
      }
    }
  }
  create_headers = local.tracing_headers
  read_headers   = local.tracing_headers
  update_headers = local.tracing_headers
  retry          = var.retry

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]
    content {
      create = timeouts.value.create
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }
}

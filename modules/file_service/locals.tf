locals {
  resource_body = {
    properties = {
      cors = var.file_service_properties.cors_rules == null ? null : {
        corsRules = [for rule in var.file_service_properties.cors_rules : {
          allowedHeaders  = rule.allowed_headers == null ? null : [for h in rule.allowed_headers : h]
          allowedMethods  = rule.allowed_methods == null ? null : [for m in rule.allowed_methods : m]
          allowedOrigins  = rule.allowed_origins == null ? null : [for o in rule.allowed_origins : o]
          exposedHeaders  = rule.exposed_headers == null ? null : [for h in rule.exposed_headers : h]
          maxAgeInSeconds = rule.max_age_in_seconds
        }]
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
      shareDeleteRetentionPolicy = var.file_service_properties.share_retention_policy == null ? null : {
        days    = var.file_service_properties.share_retention_policy.days
        enabled = var.file_service_properties.share_retention_policy.enabled
      }
    }
  }
  tracing_headers = var.tracing_tags_header == null ? null : { "User-Agent" = var.tracing_tags_header }
}

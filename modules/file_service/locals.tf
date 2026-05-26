locals {
  resource_body = {
    properties = merge(
      var.file_service_properties.cors_rules == null ? {} : {
        cors = {
          corsRules = [for rule in var.file_service_properties.cors_rules : {
            allowedHeaders  = rule.allowed_headers
            allowedMethods  = rule.allowed_methods
            allowedOrigins  = rule.allowed_origins
            exposedHeaders  = rule.exposed_headers
            maxAgeInSeconds = rule.max_age_in_seconds
          }]
        }
      },
      var.file_service_properties.smb == null ? {} : {
        protocolSettings = {
          smb = merge(
            var.file_service_properties.smb.authentication_types == null ? {} : {
              authenticationMethods = join(";", var.file_service_properties.smb.authentication_types)
            },
            var.file_service_properties.smb.channel_encryption_types == null ? {} : {
              channelEncryption = join(";", var.file_service_properties.smb.channel_encryption_types)
            },
            var.file_service_properties.smb.kerberos_ticket_encryption_type == null ? {} : {
              kerberosTicketEncryption = join(";", var.file_service_properties.smb.kerberos_ticket_encryption_type)
            },
            var.file_service_properties.smb.multichannel_enabled == null ? {} : {
              multichannel = {
                enabled = var.file_service_properties.smb.multichannel_enabled
              }
            },
            var.file_service_properties.smb.versions == null ? {} : {
              versions = join(";", var.file_service_properties.smb.versions)
            },
          )
        }
      },
      var.file_service_properties.share_retention_policy == null ? {} : {
        shareDeleteRetentionPolicy = {
          days    = var.file_service_properties.share_retention_policy.days
          enabled = var.file_service_properties.share_retention_policy.enabled
        }
      },
    )
  }
  tracing_headers = var.tracing_tags_header == null ? null : { "User-Agent" = var.tracing_tags_header }
}

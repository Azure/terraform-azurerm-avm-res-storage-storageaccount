resource "azurerm_storage_account" "this" {
  account_replication_type          = var.storage_account_account_replication_type
  account_tier                      = var.storage_account_account_tier
  location                          = var.storage_account_location
  name                              = var.storage_account_name
  resource_group_name               = var.storage_account_resource_group_name
  access_tier                       = var.storage_account_access_tier
  account_kind                      = var.storage_account_account_kind
  allow_nested_items_to_be_public   = var.storage_account_allow_nested_items_to_be_public
  allowed_copy_scope                = var.storage_account_allowed_copy_scope
  cross_tenant_replication_enabled  = var.storage_account_cross_tenant_replication_enabled
  default_to_oauth_authentication   = var.storage_account_default_to_oauth_authentication
  edge_zone                         = var.storage_account_edge_zone
  enable_https_traffic_only         = var.storage_account_enable_https_traffic_only
  infrastructure_encryption_enabled = var.storage_account_infrastructure_encryption_enabled
  is_hns_enabled                    = var.storage_account_is_hns_enabled
  large_file_share_enabled          = var.storage_account_large_file_share_enabled
  min_tls_version                   = var.storage_account_min_tls_version
  nfsv3_enabled                     = var.storage_account_nfsv3_enabled
  public_network_access_enabled     = var.storage_account_public_network_access_enabled
  queue_encryption_key_type         = var.storage_account_queue_encryption_key_type
  sftp_enabled                      = var.storage_account_sftp_enabled
  shared_access_key_enabled         = var.storage_account_shared_access_key_enabled
  table_encryption_key_type         = var.storage_account_table_encryption_key_type
  tags                              = var.storage_account_tags

  dynamic "azure_files_authentication" {
    for_each = var.storage_account_azure_files_authentication == null ? [] : [
      var.storage_account_azure_files_authentication
    ]
    content {
      directory_type = azure_files_authentication.value.directory_type

      dynamic "active_directory" {
        for_each = azure_files_authentication.value.active_directory == null ? [] : [
          azure_files_authentication.value.active_directory
        ]
        content {
          domain_guid         = active_directory.value.domain_guid
          domain_name         = active_directory.value.domain_name
          domain_sid          = active_directory.value.domain_sid
          forest_name         = active_directory.value.forest_name
          netbios_domain_name = active_directory.value.netbios_domain_name
          storage_sid         = active_directory.value.storage_sid
        }
      }
    }
  }
  dynamic "blob_properties" {
    for_each = var.storage_account_blob_properties == null ? [] : [var.storage_account_blob_properties]
    content {
      change_feed_enabled           = blob_properties.value.change_feed_enabled
      change_feed_retention_in_days = blob_properties.value.change_feed_retention_in_days
      default_service_version       = blob_properties.value.default_service_version
      last_access_time_enabled      = blob_properties.value.last_access_time_enabled
      versioning_enabled            = blob_properties.value.versioning_enabled

      dynamic "container_delete_retention_policy" {
        for_each = blob_properties.value.container_delete_retention_policy == null ? [] : [
          blob_properties.value.container_delete_retention_policy
        ]
        content {
          days = container_delete_retention_policy.value.days
        }
      }
      dynamic "cors_rule" {
        for_each = blob_properties.value.cors_rule == null ? [] : blob_properties.value.cors_rule
        content {
          allowed_headers    = cors_rule.value.allowed_headers
          allowed_methods    = cors_rule.value.allowed_methods
          allowed_origins    = cors_rule.value.allowed_origins
          exposed_headers    = cors_rule.value.exposed_headers
          max_age_in_seconds = cors_rule.value.max_age_in_seconds
        }
      }
      dynamic "delete_retention_policy" {
        for_each = blob_properties.value.delete_retention_policy == null ? [] : [
          blob_properties.value.delete_retention_policy
        ]
        content {
          days = delete_retention_policy.value.days
        }
      }
      dynamic "restore_policy" {
        for_each = blob_properties.value.restore_policy == null ? [] : [blob_properties.value.restore_policy]
        content {
          days = restore_policy.value.days
        }
      }
    }
  }
  dynamic "custom_domain" {
    for_each = var.storage_account_custom_domain == null ? [] : [var.storage_account_custom_domain]
    content {
      name          = custom_domain.value.name
      use_subdomain = custom_domain.value.use_subdomain
    }
  }
  dynamic "identity" {
    for_each = var.storage_account_identity == null ? [] : [var.storage_account_identity]
    content {
      type         = identity.value.type
      identity_ids = toset(values(identity.value.identity_ids))
    }
  }
  dynamic "immutability_policy" {
    for_each = var.storage_account_immutability_policy == null ? [] : [var.storage_account_immutability_policy]
    content {
      allow_protected_append_writes = immutability_policy.value.allow_protected_append_writes
      period_since_creation_in_days = immutability_policy.value.period_since_creation_in_days
      state                         = immutability_policy.value.state
    }
  }
  dynamic "queue_properties" {
    for_each = var.storage_account_queue_properties == null ? [] : [var.storage_account_queue_properties]
    content {
      dynamic "cors_rule" {
        for_each = queue_properties.value.cors_rule == null ? [] : queue_properties.value.cors_rule
        content {
          allowed_headers    = cors_rule.value.allowed_headers
          allowed_methods    = cors_rule.value.allowed_methods
          allowed_origins    = cors_rule.value.allowed_origins
          exposed_headers    = cors_rule.value.exposed_headers
          max_age_in_seconds = cors_rule.value.max_age_in_seconds
        }
      }
      dynamic "hour_metrics" {
        for_each = queue_properties.value.hour_metrics == null ? [] : [queue_properties.value.hour_metrics]
        content {
          enabled               = hour_metrics.value.enabled
          version               = hour_metrics.value.version
          include_apis          = hour_metrics.value.include_apis
          retention_policy_days = hour_metrics.value.retention_policy_days
        }
      }
      dynamic "logging" {
        for_each = queue_properties.value.logging == null ? [] : [queue_properties.value.logging]
        content {
          delete                = logging.value.delete
          read                  = logging.value.read
          version               = logging.value.version
          write                 = logging.value.write
          retention_policy_days = logging.value.retention_policy_days
        }
      }
      dynamic "minute_metrics" {
        for_each = queue_properties.value.minute_metrics == null ? [] : [queue_properties.value.minute_metrics]
        content {
          enabled               = minute_metrics.value.enabled
          version               = minute_metrics.value.version
          include_apis          = minute_metrics.value.include_apis
          retention_policy_days = minute_metrics.value.retention_policy_days
        }
      }
    }
  }
  dynamic "routing" {
    for_each = var.storage_account_routing == null ? [] : [var.storage_account_routing]
    content {
      choice                      = routing.value.choice
      publish_internet_endpoints  = routing.value.publish_internet_endpoints
      publish_microsoft_endpoints = routing.value.publish_microsoft_endpoints
    }
  }
  dynamic "sas_policy" {
    for_each = var.storage_account_sas_policy == null ? [] : [var.storage_account_sas_policy]
    content {
      expiration_period = sas_policy.value.expiration_period
      expiration_action = sas_policy.value.expiration_action
    }
  }
  dynamic "share_properties" {
    for_each = var.storage_account_share_properties == null ? [] : [var.storage_account_share_properties]
    content {
      dynamic "cors_rule" {
        for_each = share_properties.value.cors_rule == null ? [] : share_properties.value.cors_rule
        content {
          allowed_headers    = cors_rule.value.allowed_headers
          allowed_methods    = cors_rule.value.allowed_methods
          allowed_origins    = cors_rule.value.allowed_origins
          exposed_headers    = cors_rule.value.exposed_headers
          max_age_in_seconds = cors_rule.value.max_age_in_seconds
        }
      }
      dynamic "retention_policy" {
        for_each = share_properties.value.retention_policy == null ? [] : [share_properties.value.retention_policy]
        content {
          days = retention_policy.value.days
        }
      }
      dynamic "smb" {
        for_each = share_properties.value.smb == null ? [] : [share_properties.value.smb]
        content {
          authentication_types            = smb.value.authentication_types
          channel_encryption_type         = smb.value.channel_encryption_type
          kerberos_ticket_encryption_type = smb.value.kerberos_ticket_encryption_type
          multichannel_enabled            = smb.value.multichannel_enabled
          versions                        = smb.value.versions
        }
      }
    }
  }
  dynamic "static_website" {
    for_each = var.storage_account_static_website == null ? [] : [var.storage_account_static_website]
    content {
      error_404_document = static_website.value.error_404_document
      index_document     = static_website.value.index_document
    }
  }
  dynamic "timeouts" {
    for_each = var.storage_account_timeouts == null ? [] : [var.storage_account_timeouts]
    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }

  lifecycle {
    ignore_changes = [
      customer_managed_key
    ]
  }
}

resource "azurerm_storage_account_local_user" "this" {
  for_each = var.storage_account_local_user

  name                 = each.value.name
  storage_account_id   = azurerm_storage_account.this.id
  home_directory       = each.value.home_directory
  ssh_key_enabled      = each.value.ssh_key_enabled
  ssh_password_enabled = each.value.ssh_password_enabled

  dynamic "permission_scope" {
    for_each = each.value.permission_scope == null ? [] : each.value.permission_scope
    content {
      resource_name = permission_scope.value.resource_name
      service       = permission_scope.value.service

      dynamic "permissions" {
        for_each = [permission_scope.value.permissions]
        content {
          create = permissions.value.create
          delete = permissions.value.delete
          list   = permissions.value.list
          read   = permissions.value.read
          write  = permissions.value.write
        }
      }
    }
  }
  dynamic "ssh_authorized_key" {
    for_each = each.value.ssh_authorized_key == null ? [] : each.value.ssh_authorized_key
    content {
      key         = ssh_authorized_key.value.key
      description = ssh_authorized_key.value.description
    }
  }
  dynamic "timeouts" {
    for_each = each.value.timeouts == null ? [] : [each.value.timeouts]
    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }
}

resource "azurerm_storage_account_network_rules" "this" {
  default_action             = var.storage_account_network_rules.default_action
  storage_account_id         = azurerm_storage_account.this.id
  bypass                     = var.storage_account_network_rules.bypass
  ip_rules                   = var.storage_account_network_rules.ip_rules
  virtual_network_subnet_ids = var.storage_account_network_rules.virtual_network_subnet_ids

  dynamic "private_link_access" {
    for_each = var.storage_account_network_rules.private_link_access == null ? [] : var.storage_account_network_rules.private_link_access
    content {
      endpoint_resource_id = private_link_access.value.endpoint_resource_id
      endpoint_tenant_id   = private_link_access.value.endpoint_tenant_id
    }
  }
  dynamic "private_link_access" {
    for_each = var.new_private_endpoint == null ? [] : local.private_endpoints
    content {
      endpoint_resource_id = azurerm_private_endpoint.this[private_link_access.value].id
      endpoint_tenant_id   = data.azurerm_client_config.this.tenant_id
    }
  }
  dynamic "timeouts" {
    for_each = var.storage_account_network_rules.timeouts == null ? [] : [var.storage_account_network_rules.timeouts]
    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }

  lifecycle {
    precondition {
      condition     = var.new_private_endpoint == null || var.storage_account_network_rules.private_link_access == null
      error_message = "Cannot set `private_link_access` when `var.new_private_endpoint` is not `null`."
    }
  }
}

resource "azurerm_storage_container" "this" {
  for_each = var.storage_container

  name                  = each.value.name
  storage_account_name  = azurerm_storage_account.this.name
  container_access_type = each.value.container_access_type
  metadata              = each.value.metadata

  dynamic "timeouts" {
    for_each = each.value.timeouts == null ? [] : [each.value.timeouts]
    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }
}

resource "azurerm_key_vault_access_policy" "this" {
  for_each = var.key_vault_access_policy

  key_vault_id    = var.storage_account_customer_managed_key.key_vault_id
  object_id       = each.value.identity_principle_id
  tenant_id       = each.value.identity_tenant_id
  key_permissions = each.value.key_permissions

  dynamic "timeouts" {
    for_each = var.storage_account_customer_managed_key.timeouts == null ? [] : [
      var.storage_account_customer_managed_key.timeouts
    ]
    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }

  lifecycle {
    precondition {
      condition     = var.storage_account_identity != null && var.storage_account_identity.type == "UserAssigned" && (var.storage_account_account_kind == "StorageV2" || var.storage_account_account_tier == "Premium")
      error_message = "`var.storage_account_customer_managed_key` can only be set when the `account_kind` is set to `StorageV2` or `account_tier` set to `Premium`, and the identity type is `UserAssigned`."
    }
  }
}

resource "azurerm_storage_account_customer_managed_key" "this" {
  for_each = try(var.storage_account_customer_managed_key.key_vault_access_policy.identity_keys, {})

  key_name                  = var.storage_account_customer_managed_key.key_name
  storage_account_id        = azurerm_storage_account.this.id
  key_vault_id              = var.storage_account_customer_managed_key.key_vault_id
  key_version               = var.storage_account_customer_managed_key.key_version
  user_assigned_identity_id = var.storage_account_identity.identity_ids[each.value]

  dynamic "timeouts" {
    for_each = var.storage_account_customer_managed_key.timeouts == null ? [] : [
      var.storage_account_customer_managed_key.timeouts
    ]
    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }

  depends_on = [azurerm_key_vault_access_policy.this]

  lifecycle {
    precondition {
      condition     = var.storage_account_identity != null && var.storage_account_identity.type == "UserAssigned" && (var.storage_account_account_kind == "StorageV2" || var.storage_account_account_tier == "Premium")
      error_message = "`var.storage_account_customer_managed_key` can only be set when the `account_kind` is set to `StorageV2` or `account_tier` set to `Premium`, and the identity type is `UserAssigned`."
    }
  }
}

resource "azurerm_storage_queue" "this" {
  for_each = var.storage_queue

  name                 = each.value.name
  storage_account_name = azurerm_storage_account.this.name
  metadata             = each.value.metadata

  dynamic "timeouts" {
    for_each = each.value.timeouts == null ? [] : [each.value.timeouts]
    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }

  # We need to create these storage service in serialize otherwise we might meet dns issue
  depends_on = [azurerm_storage_container.this]
}

resource "azurerm_storage_table" "this" {
  for_each = var.storage_table

  name                 = each.value.name
  storage_account_name = azurerm_storage_account.this.name

  dynamic "acl" {
    for_each = each.value.acl == null ? [] : each.value.acl
    content {
      id = acl.value.id

      dynamic "access_policy" {
        for_each = acl.value.access_policy == null ? [] : acl.value.access_policy
        content {
          expiry      = access_policy.value.expiry
          permissions = access_policy.value.permissions
          start       = access_policy.value.start
        }
      }
    }
  }
  dynamic "timeouts" {
    for_each = each.value.timeouts == null ? [] : [each.value.timeouts]
    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }

  # We need to create these storage service in serialize otherwise we might meet dns issue
  depends_on = [azurerm_storage_container.this, azurerm_storage_queue.this]
}

resource "azurerm_storage_share" "this" {
  for_each = var.storage_share

  name                 = each.value.name
  quota                = each.value.quota
  storage_account_name = azurerm_storage_account.this.name
  access_tier          = each.value.access_tier
  enabled_protocol     = each.value.enabled_protocol
  metadata             = each.value.metadata

  dynamic "acl" {
    for_each = each.value.acl == null ? [] : each.value.acl
    content {
      id = acl.value.id

      dynamic "access_policy" {
        for_each = acl.value.access_policy == null ? [] : acl.value.access_policy
        content {
          permissions = access_policy.value.permissions
          expiry      = access_policy.value.expiry
          start       = access_policy.value.start
        }
      }
    }
  }
  dynamic "timeouts" {
    for_each = each.value.timeouts == null ? [] : [each.value.timeouts]
    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }
}
variable "storage_account_account_replication_type" {
  type        = string
  description = "(Required) Defines the type of replication to use for this storage account. Valid options are `LRS`, `GRS`, `RAGRS`, `ZRS`, `GZRS` and `RAGZRS`."
  nullable    = false
}

variable "storage_account_account_tier" {
  type        = string
  description = "(Required) Defines the Tier to use for this storage account. Valid options are `Standard` and `Premium`. For `BlockBlobStorage` and `FileStorage` accounts only `Premium` is valid. Changing this forces a new resource to be created."
  nullable    = false
}

variable "storage_account_location" {
  type        = string
  description = "(Required) Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created."
  nullable    = false
}

variable "storage_account_name" {
  type        = string
  description = "(Required) Specifies the name of the storage account. Only lowercase Alphanumeric characters allowed. Changing this forces a new resource to be created. This must be unique across the entire Azure service, not just within the resource group."
  nullable    = false
}

variable "storage_account_resource_group_name" {
  type        = string
  description = "(Required) The name of the resource group in which to create the storage account. Changing this forces a new resource to be created."
  nullable    = false
}

variable "key_vault_access_policy" {
  type = map(object({
    key_permissions = optional(list(string), [
      "Get",
      "UnwrapKey",
      "WrapKey"
    ])
    identity_principle_id = string
    identity_tenant_id    = string
    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
      read   = optional(string)
      update = optional(string)
    }))
  }))
  default     = {}
  description = <<-EOT
 Since storage account's customer managed key might require key vault permission, you can create the corresponding permission by setting this variable.

 - `key_permissions` - (Optional) A map of list of key permissions, key is user assigned identity id, the element in value list must be one or more from the following: `Backup`, `Create`, `Decrypt`, Delete, `Encrypt`, `Get`, `Import`, `List`, `Purge`, `Recover`, `Restore`, `Sign`, `UnwrapKey`, `Update`, `Verify`, `WrapKey`, `Release`, `Rotate`, `GetRotationPolicy` and `SetRotationPolicy`. Defaults to `["Get", "UnwrapKey", "WrapKey"]`
 - `identity_principle_id` - (Required) The principal ID of managed identity. Changing this forces a new resource to be created.
 - `identity_tenant_id` - (Required) The tenant ID of managed identity. Changing this forces a new resource to be created.

 ---
 `timeouts` block supports the following:
 - `create` - (Defaults to 30 minutes) Used when creating the Key Vault Access Policy.
 - `delete` - (Defaults to 30 minutes) Used when deleting the Key Vault Access Policy.
 - `read` - (Defaults to 5 minutes) Used when retrieving the Key Vault Access Policy.
 - `update` - (Defaults to 30 minutes) Used when updating the Key Vault Access Policy.
EOT
  nullable    = false
}

variable "new_private_endpoint" {
  type = object({
    resource_group_name = optional(string)
    subnet_id           = string
    tags                = optional(map(string))
    private_service_connection = object({
      name_prefix = string
    })
    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
      read   = optional(string)
      update = optional(string)
    }))
  })
  default     = null
  description = <<-EOT
 Setting this variable would create corresponding private endpoints and private dns records for storage account service.

 - `resource_group_name` - (Optional) Specifies the Name of the Resource Group within which the Private Endpoint should exist. Defaults to storage account's resource group. Changing this forces a new resource to be created.
 - `subnet_id` - (Required) The ID of the Subnet from which Private IP Addresses will be allocated for this Private Endpoint. Changing this forces a new resource to be created.
 - `tags` - (Optional) A mapping of tags to assign to the resource.

 ---
 `private_service_connection` block supports the following:
 - `name` - (Required) Specifies the Name of the Private Service Connection. Changing this forces a new resource to be created.

 ---
 `timeouts` block supports the following:
 - `create` - (Defaults to 60 minutes) Used when creating the Private Endpoint.
 - `delete` - (Defaults to 60 minutes) Used when deleting the Private Endpoint.
 - `read` - (Defaults to 5 minutes) Used when retrieving the Private Endpoint.
 - `update` - (Defaults to 60 minutes) Used when updating the Private Endpoint.
EOT
}

variable "private_dns_zone_record_tags" {
  type        = map(string)
  default     = {}
  description = "Tags for private dns zone related resources."
  nullable    = false
}

variable "private_dns_zone_record_ttl" {
  type        = number
  default     = 300
  description = "The Time To Live (TTL) of the DNS record in seconds. Defaults to `300`."
  nullable    = false
}

variable "private_dns_zones_for_private_link" {
  type = map(object({
    resource_group_name       = string
    name                      = string
    virtual_network_link_name = string
  }))
  default     = {}
  description = <<-EOT
  A map of private dns zones that used to create corresponding a records and cname records for the private endpoints, the key is static string for the storage service, like `blob`, `table`, `queue`.
  - `resource_group_name` - (Required) Specifies the resource group where the resource exists. Changing this forces a new resource to be created.
  - `name` - (Required) The name of the Private DNS Zone for private link endpoint. Must be a valid domain name, e.g.: `privatelink.blob.core.windows.net`. Changing this forces a new resource to be created.
  - `virtual_network_link_name` - (Required) The name of the Private DNS Zone Virtual Network Link.
EOT
  nullable    = false

  validation {
    condition = alltrue([
      for n, z in var.private_dns_zones_for_private_link : contains(["blob", "table", "queue"], n)
    ])
    error_message = "The map's key must be one of `blob`, `table`, `queue`."
  }
}

variable "private_dns_zones_for_public_endpoint" {
  type = map(object({
    resource_group_name       = string
    name                      = string
    virtual_network_link_name = string
  }))
  default     = {}
  description = <<-EOT
  A map of private dns zones that used to create corresponding a records and cname records for the public endpoints, the key is static string for the storage service, like `blob`, `table`, `queue`.
  - `resource_group_name` - (Required) Specifies the resource group where the resource exists. Changing this forces a new resource to be created.
  - `name` - (Required) The name of the Private DNS Zone for private link endpoint. Must be a valid domain name, e.g.: `blob.core.windows.net`. Changing this forces a new resource to be created.
  - `virtual_network_link_name` - (Required) The name of the Private DNS Zone Virtual Network Link.
EOT
  nullable    = false

  validation {
    condition = alltrue([
      for n, z in var.private_dns_zones_for_public_endpoint : contains(["blob", "table", "queue"], n)
    ])
    error_message = "The map's key must be one of `blob`, `table`, `queue`."
  }
}

variable "storage_account_access_tier" {
  type        = string
  default     = null
  description = "(Optional) Defines the access tier for `BlobStorage`, `FileStorage` and `StorageV2` accounts. Valid options are `Hot` and `Cool`, defaults to `Hot`."
}

variable "storage_account_account_kind" {
  type        = string
  default     = null
  description = "(Optional) Defines the Kind of account. Valid options are `BlobStorage`, `BlockBlobStorage`, `FileStorage`, `Storage` and `StorageV2`. Defaults to `StorageV2`."
}

variable "storage_account_allow_nested_items_to_be_public" {
  type        = bool
  default     = null
  description = "(Optional) Allow or disallow nested items within this Account to opt into being public. Defaults to `true`."
}

variable "storage_account_allowed_copy_scope" {
  type        = string
  default     = null
  description = "(Optional) Restrict copy to and from Storage Accounts within an AAD tenant or with Private Links to the same VNet. Possible values are `AAD` and `PrivateLink`."
}

variable "storage_account_azure_files_authentication" {
  type = object({
    directory_type = string
    active_directory = optional(object({
      domain_guid         = string
      domain_name         = string
      domain_sid          = string
      forest_name         = string
      netbios_domain_name = string
      storage_sid         = string
    }))
  })
  default     = null
  description = <<-EOT
 - `directory_type` - (Required) Specifies the directory service used. Possible values are `AADDS`, `AD` and `AADKERB`.

 ---
 `active_directory` block supports the following:
 - `domain_guid` - (Required) Specifies the domain GUID.
 - `domain_name` - (Required) Specifies the primary domain that the AD DNS server is authoritative for.
 - `domain_sid` - (Required) Specifies the security identifier (SID).
 - `forest_name` - (Required) Specifies the Active Directory forest.
 - `netbios_domain_name` - (Required) Specifies the NetBIOS domain name.
 - `storage_sid` - (Required) Specifies the security identifier (SID) for Azure Storage.
EOT
}

variable "storage_account_blob_properties" {
  type = object({
    change_feed_enabled           = optional(bool)
    change_feed_retention_in_days = optional(number)
    default_service_version       = optional(string)
    last_access_time_enabled      = optional(bool)
    versioning_enabled            = optional(bool)
    container_delete_retention_policy = optional(object({
      days = optional(number)
    }))
    cors_rule = optional(list(object({
      allowed_headers    = list(string)
      allowed_methods    = list(string)
      allowed_origins    = list(string)
      exposed_headers    = list(string)
      max_age_in_seconds = number
    })))
    delete_retention_policy = optional(object({
      days = optional(number)
    }))
    restore_policy = optional(object({
      days = number
    }))
  })
  default     = null
  description = <<-EOT
 - `change_feed_enabled` - (Optional) Is the blob service properties for change feed events enabled? Default to `false`.
 - `change_feed_retention_in_days` - (Optional) The duration of change feed events retention in days. The possible values are between 1 and 146000 days (400 years). Setting this to null (or omit this in the configuration file) indicates an infinite retention of the change feed.
 - `default_service_version` - (Optional) The API Version which should be used by default for requests to the Data Plane API if an incoming request doesn't specify an API Version.
 - `last_access_time_enabled` - (Optional) Is the last access time based tracking enabled? Default to `false`.
 - `versioning_enabled` - (Optional) Is versioning enabled? Default to `false`.

 ---
 `container_delete_retention_policy` block supports the following:
 - `days` - (Optional) Specifies the number of days that the container should be retained, between `1` and `365` days. Defaults to `7`.

 ---
 `cors_rule` block supports the following:
 - `allowed_headers` - (Required) A list of headers that are allowed to be a part of the cross-origin request.
 - `allowed_methods` - (Required) A list of HTTP methods that are allowed to be executed by the origin. Valid options are `DELETE`, `GET`, `HEAD`, `MERGE`, `POST`, `OPTIONS`, `PUT` or `PATCH`.
 - `allowed_origins` - (Required) A list of origin domains that will be allowed by CORS.
 - `exposed_headers` - (Required) A list of response headers that are exposed to CORS clients.
 - `max_age_in_seconds` - (Required) The number of seconds the client should cache a preflight response.

 ---
 `delete_retention_policy` block supports the following:
 - `days` - (Optional) Specifies the number of days that the blob should be retained, between `1` and `365` days. Defaults to `7`.

 ---
 `restore_policy` block supports the following:
 - `days` - (Required) Specifies the number of days that the blob can be restored, between `1` and `365` days. This must be less than the `days` specified for `delete_retention_policy`.
EOT
}

variable "storage_account_cross_tenant_replication_enabled" {
  type        = bool
  default     = null
  description = "(Optional) Should cross Tenant replication be enabled? Defaults to `true`."
}

variable "storage_account_custom_domain" {
  type = object({
    name          = string
    use_subdomain = optional(bool)
  })
  default     = null
  description = <<-EOT
 - `name` - (Required) The Custom Domain Name to use for the Storage Account, which will be validated by Azure.
 - `use_subdomain` - (Optional) Should the Custom Domain Name be validated by using indirect CNAME validation?
EOT
}

variable "storage_account_customer_managed_key" {
  type = object({
    key_name     = string
    key_vault_id = string
    key_version  = optional(string)
    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
      read   = optional(string)
      update = optional(string)
    }))
  })
  default     = null
  description = <<-EOT
 Note: `var.storage_account_customer_managed_key` can only be set when the `var.storage_account_account_kind` is set to `StorageV2` or `var.storage_account_account_kind_account_tier` set to `Premium`, and the identity type is `UserAssigned`.

 - `key_name` - (Required) The name of Key Vault Key.
 - `key_vault_id` - (Required) The ID of the Key Vault.
 - `key_version` - (Optional) The version of Key Vault Key. Remove or omit this argument to enable Automatic Key Rotation.

 ---
 `timeouts` block supports the following:
 - `create` - (Defaults to 30 minutes) Used when creating the Storage Account Customer Managed Keys.
 - `delete` - (Defaults to 30 minutes) Used when deleting the Storage Account Customer Managed Keys.
 - `read` - (Defaults to 5 minutes) Used when retrieving the Storage Account Customer Managed Keys.
 - `update` - (Defaults to 30 minutes) Used when updating the Storage Account Customer Managed Keys.
EOT
}

variable "storage_account_default_to_oauth_authentication" {
  type        = bool
  default     = null
  description = "(Optional) Default to Azure Active Directory authorization in the Azure portal when accessing the Storage Account. The default value is `false`"
}

variable "storage_account_edge_zone" {
  type        = string
  default     = null
  description = "(Optional) Specifies the Edge Zone within the Azure Region where this Storage Account should exist. Changing this forces a new Storage Account to be created."
}

variable "storage_account_enable_https_traffic_only" {
  type        = bool
  default     = null
  description = "(Optional) Boolean flag which forces HTTPS if enabled, see [here](https://docs.microsoft.com/azure/storage/storage-require-secure-transfer/) for more information. Defaults to `true`."
}

variable "storage_account_identity" {
  type = object({
    identity_ids = optional(map(string))
    type         = string
  })
  default     = null
  description = <<-EOT
 - `identity_ids` - (Optional) Specifies a list of User Assigned Managed Identity IDs to be assigned to this Storage Account.
 - `type` - (Required) Specifies the type of Managed Service Identity that should be configured on this Storage Account. Possible values are `SystemAssigned`, `UserAssigned`, `SystemAssigned, UserAssigned` (to enable both).
EOT
}

variable "storage_account_immutability_policy" {
  type = object({
    allow_protected_append_writes = bool
    period_since_creation_in_days = number
    state                         = string
  })
  default     = null
  description = <<-EOT
 - `allow_protected_append_writes` - (Required) When enabled, new blocks can be written to an append blob while maintaining immutability protection and compliance. Only new blocks can be added and any existing blocks cannot be modified or deleted.
 - `period_since_creation_in_days` - (Required) The immutability period for the blobs in the container since the policy creation, in days.
 - `state` - (Required) Defines the mode of the policy. `Disabled` state disables the policy, `Unlocked` state allows increase and decrease of immutability retention time and also allows toggling allowProtectedAppendWrites property, `Locked` state only allows the increase of the immutability retention time. A policy can only be created in a Disabled or Unlocked state and can be toggled between the two states. Only a policy in an Unlocked state can transition to a Locked state which cannot be reverted.
EOT
}

variable "storage_account_infrastructure_encryption_enabled" {
  type        = bool
  default     = null
  description = "(Optional) Is infrastructure encryption enabled? Changing this forces a new resource to be created. Defaults to `false`."
}

variable "storage_account_is_hns_enabled" {
  type        = bool
  default     = null
  description = "(Optional) Is Hierarchical Namespace enabled? This can be used with Azure Data Lake Storage Gen 2 ([see here for more information](https://docs.microsoft.com/azure/storage/blobs/data-lake-storage-quickstart-create-account/)). Changing this forces a new resource to be created."
}

variable "storage_account_large_file_share_enabled" {
  type        = bool
  default     = null
  description = "(Optional) Is Large File Share Enabled?"
}

variable "storage_account_local_user" {
  type = map(object({
    home_directory       = optional(string)
    name                 = string
    ssh_key_enabled      = optional(bool)
    ssh_password_enabled = optional(bool)
    permission_scope = optional(list(object({
      resource_name = string
      service       = string
      permissions = object({
        create = optional(bool)
        delete = optional(bool)
        list   = optional(bool)
        read   = optional(bool)
        write  = optional(bool)
      })
    })))
    ssh_authorized_key = optional(list(object({
      description = optional(string)
      key         = string
    })))
    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
      read   = optional(string)
      update = optional(string)
    }))
  }))
  default     = {}
  description = <<-EOT
 - `home_directory` - (Optional) The home directory of the Storage Account Local User.
 - `name` - (Required) The name which should be used for this Storage Account Local User. Changing this forces a new Storage Account Local User to be created.
 - `ssh_key_enabled` - (Optional) Specifies whether SSH Key Authentication is enabled. Defaults to `false`.
 - `ssh_password_enabled` - (Optional) Specifies whether SSH Password Authentication is enabled. Defaults to `false`.

 ---
 `permission_scope` block supports the following:
 - `resource_name` - (Required) The container name (when `service` is set to `blob`) or the file share name (when `service` is set to `file`), used by the Storage Account Local User.
 - `service` - (Required) The storage service used by this Storage Account Local User. Possible values are `blob` and `file`.

 ---
 `permissions` block supports the following:
 - `create` - (Optional) Specifies if the Local User has the create permission for this scope. Defaults to `false`.
 - `delete` - (Optional) Specifies if the Local User has the delete permission for this scope. Defaults to `false`.
 - `list` - (Optional) Specifies if the Local User has the list permission for this scope. Defaults to `false`.
 - `read` - (Optional) Specifies if the Local User has the read permission for this scope. Defaults to `false`.
 - `write` - (Optional) Specifies if the Local User has the write permission for this scope. Defaults to `false`.

 ---
 `ssh_authorized_key` block supports the following:
 - `description` - (Optional) The description of this SSH authorized key.
 - `key` - (Required) The public key value of this SSH authorized key.

 ---
 `timeouts` block supports the following:
 - `create` - (Defaults to 30 minutes) Used when creating the Storage Account Local User.
 - `delete` - (Defaults to 30 minutes) Used when deleting the Storage Account Local User.
 - `read` - (Defaults to 5 minutes) Used when retrieving the Storage Account Local User.
 - `update` - (Defaults to 30 minutes) Used when updating the Storage Account Local User.
EOT
  nullable    = false
}

variable "storage_account_min_tls_version" {
  type        = string
  default     = null
  description = "(Optional) The minimum supported TLS version for the storage account. Possible values are `TLS1_0`, `TLS1_1`, and `TLS1_2`. Defaults to `TLS1_2` for new storage accounts."
}

variable "storage_account_network_rules" {
  type = object({
    bypass                     = optional(set(string), ["Logging", "Metrics", "AzureServices"])
    default_action             = optional(string, "Deny")
    ip_rules                   = optional(set(string), [])
    virtual_network_subnet_ids = optional(set(string))
    private_link_access = optional(list(object({
      endpoint_resource_id = string
      endpoint_tenant_id   = optional(string)
    })))
    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
      read   = optional(string)
      update = optional(string)
    }))
  })
  default     = null
  description = <<-EOT
 - `bypass` - (Optional) Specifies whether traffic is bypassed for Logging/Metrics/AzureServices. Valid options are any combination of `Logging`, `Metrics`, `AzureServices`, or `None`.
 - `default_action` - (Required) Specifies the default action of allow or deny when no other rules match. Valid options are `Deny` or `Allow`.
 - `ip_rules` - (Optional) List of public IP or IP ranges in CIDR Format. Only IPv4 addresses are allowed. Private IP address ranges (as defined in [RFC 1918](https://tools.ietf.org/html/rfc1918#section-3)) are not allowed.
 - `storage_account_id` - (Required) Specifies the ID of the storage account. Changing this forces a new resource to be created.
 - `virtual_network_subnet_ids` - (Optional) A list of virtual network subnet ids to secure the storage account.

 ---
 `private_link_access` block supports the following:
 - `endpoint_resource_id` - (Required) The resource id of the resource access rule to be granted access.
 - `endpoint_tenant_id` - (Optional) The tenant id of the resource of the resource access rule to be granted access. Defaults to the current tenant id.

 ---
 `timeouts` block supports the following:
 - `create` - (Defaults to 60 minutes) Used when creating the  Network Rules for this Storage Account.
 - `delete` - (Defaults to 60 minutes) Used when deleting the Network Rules for this Storage Account.
 - `read` - (Defaults to 5 minutes) Used when retrieving the Network Rules for this Storage Account.
 - `update` - (Defaults to 60 minutes) Used when updating the Network Rules for this Storage Account.
EOT
}

variable "storage_account_nfsv3_enabled" {
  type        = bool
  default     = null
  description = "(Optional) Is NFSv3 protocol enabled? Changing this forces a new resource to be created. Defaults to `false`."
}

variable "storage_account_public_network_access_enabled" {
  type        = bool
  default     = null
  description = "(Optional) Whether the public network access is enabled? Defaults to `true`."
}

variable "storage_account_queue_encryption_key_type" {
  type        = string
  default     = null
  description = "(Optional) The encryption type of the queue service. Possible values are `Service` and `Account`. Changing this forces a new resource to be created. Default value is `Service`."
}

variable "storage_account_queue_properties" {
  type = object({
    cors_rule = optional(list(object({
      allowed_headers    = list(string)
      allowed_methods    = list(string)
      allowed_origins    = list(string)
      exposed_headers    = list(string)
      max_age_in_seconds = number
    })))
    hour_metrics = optional(object({
      enabled               = bool
      include_apis          = optional(bool)
      retention_policy_days = optional(number)
      version               = string
    }))
    logging = optional(object({
      delete                = bool
      read                  = bool
      retention_policy_days = optional(number)
      version               = string
      write                 = bool
    }))
    minute_metrics = optional(object({
      enabled               = bool
      include_apis          = optional(bool)
      retention_policy_days = optional(number)
      version               = string
    }))
  })
  default     = null
  description = <<-EOT

 ---
 `cors_rule` block supports the following:
 - `allowed_headers` - (Required) A list of headers that are allowed to be a part of the cross-origin request.
 - `allowed_methods` - (Required) A list of HTTP methods that are allowed to be executed by the origin. Valid options are `DELETE`, `GET`, `HEAD`, `MERGE`, `POST`, `OPTIONS`, `PUT` or `PATCH`.
 - `allowed_origins` - (Required) A list of origin domains that will be allowed by CORS.
 - `exposed_headers` - (Required) A list of response headers that are exposed to CORS clients.
 - `max_age_in_seconds` - (Required) The number of seconds the client should cache a preflight response.

 ---
 `hour_metrics` block supports the following:
 - `enabled` - (Required) Indicates whether hour metrics are enabled for the Queue service.
 - `include_apis` - (Optional) Indicates whether metrics should generate summary statistics for called API operations.
 - `retention_policy_days` - (Optional) Specifies the number of days that logs will be retained.
 - `version` - (Required) The version of storage analytics to configure.

 ---
 `logging` block supports the following:
 - `delete` - (Required) Indicates whether all delete requests should be logged.
 - `read` - (Required) Indicates whether all read requests should be logged.
 - `retention_policy_days` - (Optional) Specifies the number of days that logs will be retained.
 - `version` - (Required) The version of storage analytics to configure.
 - `write` - (Required) Indicates whether all write requests should be logged.

 ---
 `minute_metrics` block supports the following:
 - `enabled` - (Required) Indicates whether minute metrics are enabled for the Queue service.
 - `include_apis` - (Optional) Indicates whether metrics should generate summary statistics for called API operations.
 - `retention_policy_days` - (Optional) Specifies the number of days that logs will be retained.
 - `version` - (Required) The version of storage analytics to configure.
EOT
}

variable "storage_account_routing" {
  type = object({
    choice                      = optional(string)
    publish_internet_endpoints  = optional(bool)
    publish_microsoft_endpoints = optional(bool)
  })
  default     = null
  description = <<-EOT
 - `choice` - (Optional) Specifies the kind of network routing opted by the user. Possible values are `InternetRouting` and `MicrosoftRouting`. Defaults to `MicrosoftRouting`.
 - `publish_internet_endpoints` - (Optional) Should internet routing storage endpoints be published? Defaults to `false`.
 - `publish_microsoft_endpoints` - (Optional) Should Microsoft routing storage endpoints be published? Defaults to `false`.
EOT
}

variable "storage_account_sas_policy" {
  type = object({
    expiration_action = optional(string)
    expiration_period = string
  })
  default     = null
  description = <<-EOT
 - `expiration_action` - (Optional) The SAS expiration action. The only possible value is `Log` at this moment. Defaults to `Log`.
 - `expiration_period` - (Required) The SAS expiration period in format of `DD.HH:MM:SS`.
EOT
}

variable "storage_account_sftp_enabled" {
  type        = bool
  default     = null
  description = "(Optional) Boolean, enable SFTP for the storage account"
}

variable "storage_account_share_properties" {
  type = object({
    cors_rule = optional(list(object({
      allowed_headers    = list(string)
      allowed_methods    = list(string)
      allowed_origins    = list(string)
      exposed_headers    = list(string)
      max_age_in_seconds = number
    })))
    retention_policy = optional(object({
      days = optional(number)
    }))
    smb = optional(object({
      authentication_types            = optional(set(string))
      channel_encryption_type         = optional(set(string))
      kerberos_ticket_encryption_type = optional(set(string))
      multichannel_enabled            = optional(bool)
      versions                        = optional(set(string))
    }))
  })
  default     = null
  description = <<-EOT

 ---
 `cors_rule` block supports the following:
 - `allowed_headers` - (Required) A list of headers that are allowed to be a part of the cross-origin request.
 - `allowed_methods` - (Required) A list of HTTP methods that are allowed to be executed by the origin. Valid options are `DELETE`, `GET`, `HEAD`, `MERGE`, `POST`, `OPTIONS`, `PUT` or `PATCH`.
 - `allowed_origins` - (Required) A list of origin domains that will be allowed by CORS.
 - `exposed_headers` - (Required) A list of response headers that are exposed to CORS clients.
 - `max_age_in_seconds` - (Required) The number of seconds the client should cache a preflight response.

 ---
 `retention_policy` block supports the following:
 - `days` - (Optional) Specifies the number of days that the `azurerm_storage_share` should be retained, between `1` and `365` days. Defaults to `7`.

 ---
 `smb` block supports the following:
 - `authentication_types` - (Optional) A set of SMB authentication methods. Possible values are `NTLMv2`, and `Kerberos`.
 - `channel_encryption_type` - (Optional) A set of SMB channel encryption. Possible values are `AES-128-CCM`, `AES-128-GCM`, and `AES-256-GCM`.
 - `kerberos_ticket_encryption_type` - (Optional) A set of Kerberos ticket encryption. Possible values are `RC4-HMAC`, and `AES-256`.
 - `multichannel_enabled` - (Optional) Indicates whether multichannel is enabled. Defaults to `false`. This is only supported on Premium storage accounts.
 - `versions` - (Optional) A set of SMB protocol versions. Possible values are `SMB2.1`, `SMB3.0`, and `SMB3.1.1`.
EOT
}

variable "storage_account_shared_access_key_enabled" {
  type        = bool
  default     = null
  description = "(Optional) Indicates whether the storage account permits requests to be authorized with the account access key via Shared Key. If false, then all requests, including shared access signatures, must be authorized with Azure Active Directory (Azure AD). The default value is `true`."
}

variable "storage_account_static_website" {
  type = object({
    error_404_document = optional(string)
    index_document     = optional(string)
  })
  default     = null
  description = <<-EOT
 - `error_404_document` - (Optional) The absolute path to a custom webpage that should be used when a request is made which does not correspond to an existing file.
 - `index_document` - (Optional) The webpage that Azure Storage serves for requests to the root of a website or any subfolder. For example, index.html. The value is case-sensitive.
EOT
}

variable "storage_account_table_encryption_key_type" {
  type        = string
  default     = null
  description = "(Optional) The encryption type of the table service. Possible values are `Service` and `Account`. Changing this forces a new resource to be created. Default value is `Service`."
}

variable "storage_account_tags" {
  type        = map(string)
  default     = null
  description = "(Optional) A mapping of tags to assign to the resource."
}

variable "storage_account_timeouts" {
  type = object({
    create = optional(string)
    delete = optional(string)
    read   = optional(string)
    update = optional(string)
  })
  default     = null
  description = <<-EOT
 - `create` - (Defaults to 60 minutes) Used when creating the Storage Account.
 - `delete` - (Defaults to 60 minutes) Used when deleting the Storage Account.
 - `read` - (Defaults to 5 minutes) Used when retrieving the Storage Account.
 - `update` - (Defaults to 60 minutes) Used when updating the Storage Account.
EOT
}

variable "storage_container" {
  type = map(object({
    container_access_type = optional(string)
    metadata              = optional(map(string))
    name                  = string
    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
      read   = optional(string)
      update = optional(string)
    }))
  }))
  default     = {}
  description = <<-EOT
 - `container_access_type` - (Optional) The Access Level configured for this Container. Possible values are `blob`, `container` or `private`. Defaults to `private`.
 - `metadata` - (Optional) A mapping of MetaData for this Container. All metadata keys should be lowercase.
 - `name` - (Required) The name of the Container which should be created within the Storage Account. Changing this forces a new resource to be created.

 ---
 `timeouts` block supports the following:
 - `create` - (Defaults to 30 minutes) Used when creating the Storage Container.
 - `delete` - (Defaults to 30 minutes) Used when deleting the Storage Container.
 - `read` - (Defaults to 5 minutes) Used when retrieving the Storage Container.
 - `update` - (Defaults to 30 minutes) Used when updating the Storage Container.
EOT
  nullable    = false
}

variable "storage_queue" {
  type = map(object({
    metadata = optional(map(string))
    name     = string
    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
      read   = optional(string)
      update = optional(string)
    }))
  }))
  default     = {}
  description = <<-EOT
 - `metadata` - (Optional) A mapping of MetaData which should be assigned to this Storage Queue.
 - `name` - (Required) The name of the Queue which should be created within the Storage Account. Must be unique within the storage account the queue is located. Changing this forces a new resource to be created.

 ---
 `timeouts` block supports the following:
 - `create` - (Defaults to 30 minutes) Used when creating the Storage Queue.
 - `delete` - (Defaults to 30 minutes) Used when deleting the Storage Queue.
 - `read` - (Defaults to 5 minutes) Used when retrieving the Storage Queue.
 - `update` - (Defaults to 30 minutes) Used when updating the Storage Queue.
EOT
  nullable    = false
}

variable "storage_share" {
  type = map(object({
    access_tier      = optional(string)
    enabled_protocol = optional(string)
    metadata         = optional(map(string))
    name             = string
    quota            = number
    acl = optional(set(object({
      id = string
      access_policy = optional(list(object({
        expiry      = optional(string)
        permissions = string
        start       = optional(string)
      })))
    })))
    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
      read   = optional(string)
      update = optional(string)
    }))
  }))
  default     = {}
  description = <<-EOT
 - `access_tier` - (Optional) The access tier of the File Share. Possible values are `Hot`, `Cool` and `TransactionOptimized`, `Premium`.
 - `enabled_protocol` - (Optional) The protocol used for the share. Possible values are `SMB` and `NFS`. The `SMB` indicates the share can be accessed by SMBv3.0, SMBv2.1 and REST. The `NFS` indicates the share can be accessed by NFSv4.1. Defaults to `SMB`. Changing this forces a new resource to be created.
 - `metadata` - (Optional) A mapping of MetaData for this File Share.
 - `name` - (Required) The name of the share. Must be unique within the storage account where the share is located. Changing this forces a new resource to be created.
 - `quota` - (Required) The maximum size of the share, in gigabytes. For Standard storage accounts, this must be `1`GB (or higher) and at most `5120` GB (`5` TB). For Premium FileStorage storage accounts, this must be greater than 100 GB and at most `102400` GB (`100` TB).

 ---
 `acl` block supports the following:
 - `id` - (Required) The ID which should be used for this Shared Identifier.

 ---
 `access_policy` block supports the following:
 - `expiry` - (Optional) The time at which this Access Policy should be valid until, in [ISO8601](https://en.wikipedia.org/wiki/ISO_8601) format.
 - `permissions` - (Required) The permissions which should be associated with this Shared Identifier. Possible value is combination of `r` (read), `w` (write), `d` (delete), and `l` (list).
 - `start` - (Optional) The time at which this Access Policy should be valid from, in [ISO8601](https://en.wikipedia.org/wiki/ISO_8601) format.

 ---
 `timeouts` block supports the following:
 - `create` - (Defaults to 30 minutes) Used when creating the Storage Share.
 - `delete` - (Defaults to 30 minutes) Used when deleting the Storage Share.
 - `read` - (Defaults to 5 minutes) Used when retrieving the Storage Share.
 - `update` - (Defaults to 30 minutes) Used when updating the Storage Share.
EOT
  nullable    = false
}

variable "storage_table" {
  type = map(object({
    name = string
    acl = optional(set(object({
      id = string
      access_policy = optional(list(object({
        expiry      = string
        permissions = string
        start       = string
      })))
    })))
    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
      read   = optional(string)
      update = optional(string)
    }))
  }))
  default     = {}
  description = <<-EOT
 - `name` - (Required) The name of the storage table. Only Alphanumeric characters allowed, starting with a letter. Must be unique within the storage account the table is located. Changing this forces a new resource to be created.

 ---
 `acl` block supports the following:
 - `id` - (Required) The ID which should be used for this Shared Identifier.

 ---
 `access_policy` block supports the following:
 - `expiry` - (Required) The ISO8061 UTC time at which this Access Policy should be valid until.
 - `permissions` - (Required) The permissions which should associated with this Shared Identifier.
 - `start` - (Required) The ISO8061 UTC time at which this Access Policy should be valid from.

 ---
 `timeouts` block supports the following:
 - `create` - (Defaults to 30 minutes) Used when creating the Storage Table.
 - `delete` - (Defaults to 30 minutes) Used when deleting the Storage Table.
 - `read` - (Defaults to 5 minutes) Used when retrieving the Storage Table.
 - `update` - (Defaults to 30 minutes) Used when updating the Storage Table.
EOT
  nullable    = false
}

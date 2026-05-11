# `variable "timeouts"` is declared in variables.tf (the AzAPI-flavoured
# definition that flows through to all submodules).
variable "access_tier" {
  type        = string
  default     = "Hot"
  description = "(Optional) Defines the access tier for BlobStorage, FileStorage and StorageV2 accounts. Valid options are Hot, Cool, Cold and Premium. Defaults to Hot."

  validation {
    condition     = contains(["Hot", "Cool", "Premium", "Cold"], var.access_tier)
    error_message = "Invalid value for access tier. Valid options are 'Hot', 'Cool','Premium' or 'Cold'."
  }
}

variable "account_kind" {
  type        = string
  default     = "StorageV2"
  description = "(Optional) Defines the Kind of account. Valid options are `BlobStorage`, `BlockBlobStorage`, `FileStorage`, `Storage` and `StorageV2`. Defaults to `StorageV2`."

  validation {
    condition     = contains(["BlobStorage", "BlockBlobStorage", "FileStorage", "Storage", "StorageV2"], var.account_kind)
    error_message = "Invalid value for account kind. Valid options are `BlobStorage`, `BlockBlobStorage`, `FileStorage`, `Storage` and `StorageV2`. Defaults to `StorageV2`."
  }
}

variable "account_replication_type" {
  type        = string
  default     = "ZRS"
  description = "[DEPRECATED] (Optional) Defines the type of replication to use for this storage account. Valid options are `LRS`, `GRS`, `RAGRS`, `ZRS`, `GZRS` and `RAGZRS`. Defaults to `ZRS`. This variable is only honoured when `account_sku_name` is set to `null`; otherwise `account_sku_name` wins. Prefer `account_sku_name`."
  nullable    = false

  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], var.account_replication_type)
    error_message = "Invalid value for replication type. Valid options are `LRS`, `GRS`, `RAGRS`, `ZRS`, `GZRS` and `RAGZRS`."
  }
}

variable "account_sku_name" {
  type        = string
  default     = "StandardV2_ZRS"
  description = "(Optional) Explicit storage account SKU name (e.g. `Standard_LRS`, `Premium_ZRS`, `PremiumV2_LRS`, `StandardV2_GZRS`). When set, this value is sent to Azure verbatim and overrides the SKU derived from `account_tier`, `account_replication_type` and `provisioned_billing_model_version` - those variables are only honoured when `account_sku_name` is explicitly set to `null`. Defaults to `StandardV2_ZRS`."

  validation {
    condition     = var.account_sku_name == null || can(regex("^(Standard|Premium)(V2)?_(LRS|GRS|RAGRS|ZRS|GZRS|RAGZRS)$", coalesce(var.account_sku_name, "Standard_LRS")))
    error_message = "Invalid value for `account_sku_name`. Must be in the form `<tier>[V2]_<replication>`, for example `Standard_LRS`, `Premium_ZRS`, `PremiumV2_LRS`, `StandardV2_GZRS`."
  }
}

variable "account_tier" {
  type        = string
  default     = "Standard"
  description = "[DEPRECATED] (Optional) Defines the Tier to use for this storage account. Valid options are `Standard` and `Premium`. For `BlockBlobStorage` and `FileStorage` accounts only `Premium` is valid. Changing this forces a new resource to be created. Defaults to `Standard`. This variable is only honoured when `account_sku_name` is set to `null`; otherwise `account_sku_name` wins. Prefer `account_sku_name`."
  nullable    = false

  validation {
    condition     = contains(["Standard", "Premium"], var.account_tier)
    error_message = "Invalid value for account tier. Valid options are `Standard` and `Premium`. For `BlockBlobStorage` and `FileStorage` accounts only `Premium` is valid. Changing this forces a new resource to be created."
  }
}

variable "allow_nested_items_to_be_public" {
  type        = bool
  default     = false
  description = "(Optional) Allow or disallow nested items within this Account to opt into being public. Defaults to `false`."
}

variable "allowed_copy_scope" {
  type        = string
  default     = null
  description = "(Optional) Restrict copy to and from Storage Accounts within an AAD tenant or with Private Links to the same VNet. Possible values are `AAD` and `PrivateLink`. Defaults to `null` (no restriction)."
}

variable "cross_tenant_replication_enabled" {
  type        = bool
  default     = false
  description = "(Optional) Should cross Tenant replication be enabled? Defaults to `false`."
}

variable "custom_domain" {
  type = object({
    name          = string
    use_subdomain = optional(bool)
  })
  default     = null
  description = <<-EOT
Configures a custom domain for the storage account. Defaults to `null` (no custom domain).

- `name` - (Required) The Custom Domain Name to use for the Storage Account, which will be validated by Azure.
- `use_subdomain` - (Optional) Should the Custom Domain Name be validated by using indirect CNAME validation? Defaults to `null`.
EOT
}

variable "default_to_oauth_authentication" {
  type        = bool
  default     = null
  description = "(Optional) Default to Azure Active Directory authorization in the Azure portal when accessing the Storage Account. Defaults to `null` (Azure platform default of `false`)."
}

variable "edge_zone" {
  type        = string
  default     = null
  description = "(Optional) Specifies the Edge Zone within the Azure Region where this Storage Account should exist. Defaults to `null`. Changing this forces a new Storage Account to be created."
}

variable "https_traffic_only_enabled" {
  type        = bool
  default     = true
  description = "(Optional) Boolean flag which forces HTTPS if enabled, see [here](https://docs.microsoft.com/azure/storage/storage-require-secure-transfer/) for more information. Defaults to `true`."
}

variable "infrastructure_encryption_enabled" {
  type        = bool
  default     = false
  description = "(Optional) Is infrastructure encryption enabled? Changing this forces a new resource to be created. Defaults to `false`."
}

variable "local_user" {
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
A map of Storage Account Local Users to create. The map key is arbitrary; the value supports the following attributes. Defaults to `{}` (no local users).

- `name` - (Required) The name which should be used for this Storage Account Local User. Changing this forces a new Storage Account Local User to be created.
- `home_directory` - (Optional) The home directory of the Storage Account Local User. Defaults to `null`.
- `ssh_key_enabled` - (Optional) Specifies whether SSH Key Authentication is enabled. Defaults to `null` (Azure platform default of `false`).
- `ssh_password_enabled` - (Optional) Specifies whether SSH Password Authentication is enabled. Defaults to `null` (Azure platform default of `false`).
- `permission_scope` - (Optional) A list of permission scopes for the local user. Defaults to `null`. Each entry supports:
  - `resource_name` - (Required) The container name (when `service` is set to `blob`) or the file share name (when `service` is set to `file`).
  - `service` - (Required) The storage service used by this Storage Account Local User. Possible values are `blob` and `file`.
  - `permissions` - (Required) An object describing the permissions granted at this scope. Supports:
    - `create` - (Optional) Whether the local user has the create permission for this scope. Defaults to `null` (`false`).
    - `delete` - (Optional) Whether the local user has the delete permission for this scope. Defaults to `null` (`false`).
    - `list` - (Optional) Whether the local user has the list permission for this scope. Defaults to `null` (`false`).
    - `read` - (Optional) Whether the local user has the read permission for this scope. Defaults to `null` (`false`).
    - `write` - (Optional) Whether the local user has the write permission for this scope. Defaults to `null` (`false`).
- `ssh_authorized_key` - (Optional) A list of SSH authorized keys for the local user. Defaults to `null`. Each entry supports:
  - `key` - (Required) The public key value of this SSH authorized key.
  - `description` - (Optional) The description of this SSH authorized key. Defaults to `null`.
- `timeouts` - (Optional) Per-operation timeouts for the local user resource. Defaults to `null` (uses provider defaults inherited from `var.timeouts`). Supports:
  - `create` - (Optional) Timeout for create operations.
  - `delete` - (Optional) Timeout for delete operations.
  - `read` - (Optional) Timeout for read operations.
  - `update` - (Optional) Timeout for update operations.
EOT
  nullable    = false
}

variable "local_user_enabled" {
  type        = bool
  default     = false
  description = "(Optional) Should Storage Account Local Users be enabled? Defaults to `false`."
}

variable "min_tls_version" {
  type        = string
  default     = "TLS1_2"
  description = "(Optional) The minimum supported TLS version for the storage account. Possible values are `TLS1_0`, `TLS1_1`, and `TLS1_2`. Defaults to `TLS1_2` for new storage accounts."
}

variable "network_rules" {
  type = object({
    bypass                     = optional(set(string), ["AzureServices"])
    default_action             = optional(string, "Deny")
    ip_rules                   = optional(set(string), [])
    virtual_network_subnet_ids = optional(set(string), [])
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
  default     = {}
  description = <<-EOT
Network rules restricting access to the storage account. Defaults to `{}`, which applies the object's own per-attribute defaults (effectively `default_action = "Deny"` with `bypass = ["AzureServices"]`).

> Note: the default value blocks all public access to the storage account. If you want to disable all network rules, set this value to `null`.

- `bypass` - (Optional) Specifies whether traffic is bypassed for Logging/Metrics/AzureServices. Valid options are any combination of `Logging`, `Metrics`, `AzureServices`, or `None`. Defaults to `["AzureServices"]`.
- `default_action` - (Optional) Specifies the default action of allow or deny when no other rules match. Valid options are `Deny` or `Allow`. Defaults to `Deny`.
- `ip_rules` - (Optional) List of public IP or IP ranges in CIDR format. Only IPv4 addresses are allowed. Private IP address ranges (as defined in [RFC 1918](https://tools.ietf.org/html/rfc1918#section-3)) are not allowed. Defaults to `[]`.
- `virtual_network_subnet_ids` - (Optional) A set of virtual network subnet IDs to secure the storage account. Defaults to `[]`.
- `private_link_access` - (Optional) A list of private link access rules. Defaults to `null`. Each entry supports:
  - `endpoint_resource_id` - (Required) The resource ID of the resource access rule to be granted access.
  - `endpoint_tenant_id` - (Optional) The tenant ID of the resource of the resource access rule to be granted access. Defaults to the current tenant ID.
- `timeouts` - (Optional) Per-operation timeouts for the network rules resource. Defaults to `null` (uses provider defaults). Supports:
  - `create` - (Optional) Timeout for create operations.
  - `delete` - (Optional) Timeout for delete operations.
  - `read` - (Optional) Timeout for read operations.
  - `update` - (Optional) Timeout for update operations.
EOT
}

variable "nfsv3_enabled" {
  type        = bool
  default     = false
  description = "(Optional) Is NFSv3 protocol enabled? Changing this forces a new resource to be created. Defaults to `false`."
}

variable "provisioned_billing_model_version" {
  type        = string
  default     = null
  description = "[DEPRECATED] (Optional) Specifies the version of the provisioned billing model (e.g. when `account_kind = \"FileStorage\"` for Storage File). Possible value is `V2`. Defaults to `null`. Changing this forces a new resource to be created. This variable is only honoured when `account_sku_name` is set to `null`; otherwise `account_sku_name` wins. Prefer `account_sku_name` (use a `*V2_*` SKU such as `StandardV2_ZRS` or `PremiumV2_ZRS`)."

  validation {
    condition     = var.provisioned_billing_model_version == null || var.provisioned_billing_model_version == "V2"
    error_message = "Invalid value for provisioned_billing_model_version. Valid options are `V2`."
  }
}

variable "public_network_access_enabled" {
  type        = bool
  default     = false
  description = "(Optional) Whether the public network access is enabled? Defaults to `false`."
}

variable "routing" {
  type = object({
    choice                      = optional(string, "MicrosoftRouting")
    publish_internet_endpoints  = optional(bool, false)
    publish_microsoft_endpoints = optional(bool, false)
  })
  default     = null
  description = <<-EOT
Configures the storage account routing preference. Defaults to `null` (Azure platform defaults).

- `choice` - (Optional) Specifies the kind of network routing opted by the user. Possible values are `InternetRouting` and `MicrosoftRouting`. Defaults to `MicrosoftRouting`.
- `publish_internet_endpoints` - (Optional) Should internet routing storage endpoints be published? Defaults to `false`.
- `publish_microsoft_endpoints` - (Optional) Should Microsoft routing storage endpoints be published? Defaults to `false`.
EOT
}

variable "sas_policy" {
  type = object({
    expiration_action = optional(string, "Log")
    expiration_period = string
  })
  default     = null
  description = <<-EOT
Configures the SAS policy on the storage account. Defaults to `null` (no SAS policy).

- `expiration_period` - (Required) The SAS expiration period in the format `DD.HH:MM:SS`.
- `expiration_action` - (Optional) The SAS expiration action. The only possible value is `Log` at this moment. Defaults to `Log`.
EOT
}

variable "sftp_enabled" {
  type        = bool
  default     = false
  description = "(Optional) Boolean, enable SFTP for the storage account.  Defaults to `false`."
}

variable "shared_access_key_enabled" {
  type        = bool
  default     = false
  description = "(Optional) Indicates whether the storage account permits requests to be authorized with the account access key via Shared Key. If `false`, then all requests, including shared access signatures, must be authorized with Azure Active Directory (Azure AD). Defaults to `false`."
}

variable "static_website" {
  type = map(object({
    error_404_document = optional(string)
    index_document     = optional(string)
  }))
  default     = null
  description = <<-EOT
A map of static website configurations to apply to the storage account. Defaults to `null` (static website disabled). The map key is arbitrary; only the first entry is used by the underlying API.

- `error_404_document` - (Optional) The absolute path to a custom webpage that should be used when a request is made which does not correspond to an existing file. Defaults to `null`.
- `index_document` - (Optional) The webpage that Azure Storage serves for requests to the root of a website or any subfolder. For example, `index.html`. The value is case-sensitive. Defaults to `null`.
EOT
}

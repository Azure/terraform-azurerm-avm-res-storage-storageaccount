variable "azure_files_authentication" {
  type = object({
    directory_type                 = optional(string, "AADKERB")
    default_share_level_permission = optional(string)

    active_directory = optional(object({
      domain_guid         = string
      domain_name         = string
      domain_sid          = optional(string)
      forest_name         = optional(string)
      netbios_domain_name = optional(string)
      storage_sid         = optional(string)
    }))
  })
  default     = null
  description = <<-EOT
Configures Azure Files identity-based authentication on the storage account. Defaults to `null` (no Files authentication configured).

- `directory_type` - (Optional) Specifies the directory service used. Possible values are `AADDS`, `AD`, and `AADKERB`. Defaults to `AADKERB`.
- `default_share_level_permission` - (Optional) Specifies the default share-level permission applied to all users. Possible values are `StorageFileDataSmbShareReader`, `StorageFileDataSmbShareContributor`, `StorageFileDataSmbShareElevatedContributor`, or `None`. Defaults to `null`.
- `active_directory` - (Optional) An Active Directory configuration block. Required when `directory_type` is `AD`. Defaults to `null`. Supports:
  - `domain_guid` - (Required) Specifies the domain GUID.
  - `domain_name` - (Required) Specifies the primary domain that the AD DNS server is authoritative for.
  - `domain_sid` - (Optional) Specifies the security identifier (SID). Required when `directory_type` is `AD`. Defaults to `null`.
  - `forest_name` - (Optional) Specifies the Active Directory forest. Required when `directory_type` is `AD`. Defaults to `null`.
  - `netbios_domain_name` - (Optional) Specifies the NetBIOS domain name. Required when `directory_type` is `AD`. Defaults to `null`.
  - `storage_sid` - (Optional) Specifies the security identifier (SID) for Azure Storage. Required when `directory_type` is `AD`. Defaults to `null`.
EOT

  validation {
    condition = try(
      var.azure_files_authentication.directory_type != "AD" || (
        var.azure_files_authentication.active_directory.domain_sid != null &&
        var.azure_files_authentication.active_directory.storage_sid != null &&
        var.azure_files_authentication.active_directory.forest_name != null &&
        var.azure_files_authentication.active_directory.netbios_domain_name != null
      ),
      true
    )
    error_message = "When directory_type is 'AD', active_directory block with domain_sid, storage_sid, forest_name, and netbios_domain_name is required."
  }
}

variable "large_file_share_enabled" {
  type        = bool
  default     = null
  description = "(Optional) Is large file share enabled? Defaults to `null` (Azure platform default of `false`)."
}

variable "shares" {
  type = map(object({
    access_tier      = optional(string)
    enabled_protocol = optional(string)
    metadata         = optional(map(string))
    name             = string
    quota            = number
    root_squash      = optional(string)
    signed_identifiers = optional(list(object({
      id = string
      access_policy = optional(object({
        expiry_time = string
        permission  = string
        start_time  = string
      }))
    })))
    role_assignments = optional(map(object({
      role_definition_id_or_name             = string
      principal_id                           = string
      principal_type                         = optional(string, null)
      description                            = optional(string, null)
      skip_service_principal_aad_check       = optional(bool, false)
      condition                              = optional(string, null)
      condition_version                      = optional(string, null)
      delegated_managed_identity_resource_id = optional(string, null)
    })), {})
    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
      read   = optional(string)
      update = optional(string)
    }))
  }))
  default     = {}
  description = <<-EOT
A map of file shares to create on the storage account. The map key is arbitrary; the value supports the following attributes. Defaults to `{}` (no shares).

- `name` - (Required) The name of the share. Must be unique within the storage account. Changing this forces a new resource to be created.
- `quota` - (Required) The maximum size of the share, in gigabytes. For Standard storage accounts, this must be `1` GB or higher and at most `5120` GB (5 TB). For Premium FileStorage accounts, this must be greater than 100 GB and at most `102400` GB (100 TB).
- `access_tier` - (Optional) The access tier of the file share. Possible values are `Hot`, `Cool`, `TransactionOptimized`, `Premium`. Defaults to `null` (Azure platform default).
- `enabled_protocol` - (Optional) The protocol used for the share. Possible values are `SMB` and `NFS`. `SMB` indicates the share can be accessed by SMBv3.0, SMBv2.1 and REST. `NFS` indicates the share can be accessed by NFSv4.1. Defaults to `null` (Azure platform default of `SMB`). Changing this forces a new resource to be created.
- `metadata` - (Optional) A mapping of MetaData for this File Share. Defaults to `null`.
- `root_squash` - (Optional) The root squash behaviour for an NFS share. Possible values are `NoRootSquash`, `RootSquash`, `AllSquash`. Defaults to `null`.
- `signed_identifiers` - (Optional) A list of signed identifiers (stored access policies) to apply to the share. Defaults to `null`. Each entry supports:
  - `id` - (Required) The ID for this signed identifier. Maximum 64 characters.
  - `access_policy` - (Optional) The access policy for this identifier. Defaults to `null`. Supports:
    - `expiry_time` - (Required) The [ISO8601](https://en.wikipedia.org/wiki/ISO_8601) UTC time at which this access policy should expire.
    - `permission` - (Required) The permissions associated with this signed identifier. A combination of `r` (read), `w` (write), `d` (delete), and `l` (list).
    - `start_time` - (Required) The [ISO8601](https://en.wikipedia.org/wiki/ISO_8601) UTC time at which this access policy becomes valid.
- `role_assignments` - (Optional) A map of role assignments to create on the share. Defaults to `{}`. See `var.role_assignments` for the attribute schema.
- `timeouts` - (Optional) Per-operation timeouts for the share resource. Defaults to `null` (uses provider defaults inherited from `var.timeouts`). Supports:
  - `create` - (Optional) Timeout for create operations.
  - `delete` - (Optional) Timeout for delete operations.
  - `read` - (Optional) Timeout for read operations.
  - `update` - (Optional) Timeout for update operations.
EOT
  nullable    = false
}

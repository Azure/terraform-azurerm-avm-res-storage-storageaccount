# NOTE: var.share_properties (file service-level CORS, retention policy, SMB
# settings, diagnostics) was removed in v1.0.0 (azapi rewrite). Configure those
# settings directly via Microsoft.Storage/storageAccounts/fileServices if
# needed; this module no longer exposes them.

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
 - `directory_type` - (Required) Specifies the directory service used. Possible values are `AADDS`, `AD` and `AADKERB`.
 - `default_share_level_permission` - (Optional) Specifies the default share level permissions applied to all users. Possible values are StorageFileDataSmbShareReader, StorageFileDataSmbShareContributor, StorageFileDataSmbShareElevatedContributor, or None.

 ---
 `active_directory`-(Optional) A active_directory block as defined below. Required when directory_type is `AD`.:
 - `domain_guid` - (Required) Specifies the domain GUID.
 - `domain_name` - (Required) Specifies the primary domain that the AD DNS server is authoritative for.
 - `domain_sid` - (Optional) Specifies the security identifier (SID).This is required when `directory_type` is set to `AD`.
 - `forest_name` - (Optional) Specifies the Active Directory forest. This is required when `directory_type` is set to `AD`.
 - `netbios_domain_name` - (Optional) Specifies the NetBIOS domain name.This is required when `directory_type` is set to `AD`.
 - `storage_sid` - (Optional) Specifies the security identifier (SID) for Azure Storage.This is required when `directory_type` is set to `AD`.
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
  description = "(Optional) Is Large File Share Enabled?"
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

Supply role assignments in the same way as for `var.role_assignments`.

EOT
  nullable    = false
}

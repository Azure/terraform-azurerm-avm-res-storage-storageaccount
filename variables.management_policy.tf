# variable "storage_management_policy_storage_account_id" {
#   type        = string
#   description = "(Required) Specifies the id of the storage account to apply the management policy to. Changing this forces a new resource to be created."
#   nullable    = false
# }

variable "storage_management_policy_rule" {
  type = map(object({
    enabled = bool
    name    = string
    actions = object({
      base_blob = optional(object({
        auto_tier_to_hot_from_cool_enabled                             = optional(bool)
        delete_after_days_since_creation_greater_than                  = optional(number)
        delete_after_days_since_last_access_time_greater_than          = optional(number)
        delete_after_days_since_modification_greater_than              = optional(number)
        tier_to_archive_after_days_since_creation_greater_than         = optional(number)
        tier_to_archive_after_days_since_last_access_time_greater_than = optional(number)
        tier_to_archive_after_days_since_last_tier_change_greater_than = optional(number)
        tier_to_archive_after_days_since_modification_greater_than     = optional(number)
        tier_to_cold_after_days_since_creation_greater_than            = optional(number)
        tier_to_cold_after_days_since_last_access_time_greater_than    = optional(number)
        tier_to_cold_after_days_since_modification_greater_than        = optional(number)
        tier_to_cool_after_days_since_creation_greater_than            = optional(number)
        tier_to_cool_after_days_since_last_access_time_greater_than    = optional(number)
        tier_to_cool_after_days_since_modification_greater_than        = optional(number)
      }))
      snapshot = optional(object({
        change_tier_to_archive_after_days_since_creation               = optional(number)
        change_tier_to_cool_after_days_since_creation                  = optional(number)
        delete_after_days_since_creation_greater_than                  = optional(number)
        tier_to_archive_after_days_since_last_tier_change_greater_than = optional(number)
        tier_to_cold_after_days_since_creation_greater_than            = optional(number)
      }))
      version = optional(object({
        change_tier_to_archive_after_days_since_creation               = optional(number)
        change_tier_to_cool_after_days_since_creation                  = optional(number)
        delete_after_days_since_creation                               = optional(number)
        tier_to_archive_after_days_since_last_tier_change_greater_than = optional(number)
        tier_to_cold_after_days_since_creation_greater_than            = optional(number)
      }))
    })
    filters = object({
      blob_types   = set(string)
      prefix_match = optional(set(string))
      match_blob_index_tag = optional(set(object({
        name      = string
        operation = optional(string)
        value     = string
      })))
    })
  }))
  default     = {}
  description = <<-EOT
A map of management policy rules to apply to the storage account. The map key is arbitrary; the value supports the following attributes. Defaults to `{}` (no rules).

- `enabled` - (Required) Boolean to specify whether the rule is enabled.
- `name` - (Required) The name of the rule. Rule name is case-sensitive. It must be unique within a policy.
- `actions` - (Required) An object describing the actions taken by the rule. Supports the following nested blocks (each `optional`, defaults to `null`):

 ---
 `base_blob` block supports the following:
 - `auto_tier_to_hot_from_cool_enabled` - (Optional) Whether a blob should automatically be tiered from cool back to hot if it's accessed again after being tiered to cool. Defaults to `false`.
 - `delete_after_days_since_creation_greater_than` - (Optional) The age in days after creation to delete the blob. Must be between `0` and `99999`. Defaults to `-1`.
 - `delete_after_days_since_last_access_time_greater_than` - (Optional) The age in days after last access time to delete the blob. Must be between `0` and `99999`. Defaults to `-1`.
 - `delete_after_days_since_modification_greater_than` - (Optional) The age in days after last modification to delete the blob. Must be between 0 and 99999. Defaults to `-1`.
 - `tier_to_archive_after_days_since_creation_greater_than` - (Optional) The age in days after creation to archive storage. Supports blob currently at Hot or Cool tier. Must be between `0` and`99999`. Defaults to `-1`.
 - `tier_to_archive_after_days_since_last_access_time_greater_than` - (Optional) The age in days after last access time to tier blobs to archive storage. Supports blob currently at Hot or Cool tier. Must be between `0` and`99999`. Defaults to `-1`.
 - `tier_to_archive_after_days_since_last_tier_change_greater_than` - (Optional) The age in days after last tier change to the blobs to skip to be archved. Must be between 0 and 99999. Defaults to `-1`.
 - `tier_to_archive_after_days_since_modification_greater_than` - (Optional) The age in days after last modification to tier blobs to archive storage. Supports blob currently at Hot or Cool tier. Must be between 0 and 99999. Defaults to `-1`.
 - `tier_to_cold_after_days_since_creation_greater_than` - (Optional) The age in days after creation to cold storage. Supports blob currently at Hot tier. Must be between `0` and `99999`. Defaults to `-1`.
 - `tier_to_cold_after_days_since_last_access_time_greater_than` - (Optional) The age in days after last access time to tier blobs to cold storage. Supports blob currently at Hot tier. Must be between `0` and `99999`. Defaults to `-1`.
 - `tier_to_cold_after_days_since_modification_greater_than` - (Optional) The age in days after last modification to tier blobs to cold storage. Supports blob currently at Hot tier. Must be between 0 and 99999. Defaults to `-1`.
 - `tier_to_cool_after_days_since_creation_greater_than` - (Optional) The age in days after creation to cool storage. Supports blob currently at Hot tier. Must be between `0` and `99999`. Defaults to `-1`.
 - `tier_to_cool_after_days_since_last_access_time_greater_than` - (Optional) The age in days after last access time to tier blobs to cool storage. Supports blob currently at Hot tier. Must be between `0` and `99999`. Defaults to `-1`.
 - `tier_to_cool_after_days_since_modification_greater_than` - (Optional) The age in days after last modification to tier blobs to cool storage. Supports blob currently at Hot tier. Must be between 0 and 99999. Defaults to `-1`.

 ---
 `snapshot` block supports the following:
 - `change_tier_to_archive_after_days_since_creation` - (Optional) The age in days after creation to tier blob snapshot to archive storage. Must be between 0 and 99999. Defaults to `-1`.
 - `change_tier_to_cool_after_days_since_creation` - (Optional) The age in days after creation to tier blob snapshot to cool storage. Must be between 0 and 99999. Defaults to `-1`.
 - `delete_after_days_since_creation_greater_than` - (Optional) The age in days after creation to delete the blob snapshot. Must be between 0 and 99999. Defaults to `-1`.
 - `tier_to_archive_after_days_since_last_tier_change_greater_than` - (Optional) The age in days after last tier change to the blobs to skip to be archved. Must be between 0 and 99999. Defaults to `-1`.
 - `tier_to_cold_after_days_since_creation_greater_than` - (Optional) The age in days after creation to cold storage. Supports blob currently at Hot tier. Must be between `0` and `99999`. Defaults to `-1`.

 ---
 `version` block supports the following:
 - `change_tier_to_archive_after_days_since_creation` - (Optional) The age in days after creation to tier blob version to archive storage. Must be between 0 and 99999. Defaults to `-1`.
 - `change_tier_to_cool_after_days_since_creation` - (Optional) The age in days creation create to tier blob version to cool storage. Must be between 0 and 99999. Defaults to `-1`.
 - `delete_after_days_since_creation` - (Optional) The age in days after creation to delete the blob version. Must be between 0 and 99999. Defaults to `-1`.
 - `tier_to_archive_after_days_since_last_tier_change_greater_than` - (Optional) The age in days after last tier change to the blobs to skip to be archved. Must be between 0 and 99999. Defaults to `-1`.
 - `tier_to_cold_after_days_since_creation_greater_than` - (Optional) The age in days after creation to cold storage. Supports blob currently at Hot tier. Must be between `0` and `99999`. Defaults to `-1`.

 ---
 `filters` block (Required) supports the following:
 - `blob_types` - (Required) A set of predefined values. Valid options are `blockBlob` and `appendBlob`.
 - `prefix_match` - (Optional) A set of strings for prefixes to be matched. Defaults to `null`.
 - `match_blob_index_tag` - (Optional) A set of blob index tag filters. Defaults to `null`. Each entry supports the attributes documented in the `match_blob_index_tag` block below.

 ---
 `match_blob_index_tag` block supports the following:
 - `name` - (Required) The filter tag name used for tag based filtering for blob objects.
 - `value` - (Required) The filter tag value used for tag based filtering for blob objects.
 - `operation` - (Optional) The comparison operator which is used for object comparison and filtering. Possible value is `==`. Defaults to `null` (Azure platform default of `==`).
EOT
  nullable    = false
}

variable "storage_management_policy_timeouts" {
  type = object({
    create = optional(string)
    delete = optional(string)
    read   = optional(string)
    update = optional(string)
  })
  default     = null
  description = <<-EOT
Per-operation timeouts for the storage account management policy resource. Defaults to `null` (uses provider defaults).

- `create` - (Optional) Timeout for create operations. Defaults to `null`.
- `delete` - (Optional) Timeout for delete operations. Defaults to `null`.
- `read` - (Optional) Timeout for read operations. Defaults to `null`.
- `update` - (Optional) Timeout for update operations. Defaults to `null`.
EOT
}

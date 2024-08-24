variable "management_policy" {
  type = map(object({
    rule = object({
      name = string
      enabled = bool
      filters = optional(object({
        prefix_match = optional(list(string))
        blob_types = optional(list(string))
      }))
      match_blob_index_tags = optional(object({
        name = optional(string)
        value = optional(string)
        operation = optional(string)
      }))

      actions = optional(object({
        base_blob = optional(object({
          tier_to_cool_after_days_since_modification_greater_than = optional(number)
          tier_to_archive_after_days_since_modification_greater_than = optional(number)
          delete_after_days_since_modification_greater_than   = optional(number)
        }))
        snapshot = optional(object({
          delete_after_days_since_creation_greater_than = optional(number)
        }))
        version = optional(object({
          change_tier_to_archive_after_days_since_creation = optional(number)
          change_tier_to_cool_after_days_since_creation = optional(number)
          delete_after_days_since_creation = optional(number)
        }))
      }))
    })

  }))
}



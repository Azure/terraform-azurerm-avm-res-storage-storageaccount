resource "azurerm_storage_management_policy" "this" {
  storage_account_id = azurerm_storage_account.this.id

  dynamic "rule" {
    for_each = var.management_policy.rule
    content {
      name = rule.value.name
      enabled = rule.value.enabled

      dynamic "filters" {
        for_each = try(rule.value.filters, {})
        content {
          prefix_match = try(filters.value.prefix_match, null)
          blob_types   = try(filters.value.blob_types, null)
        }

      }
      dynamic "match_blob_index_tags" {
        for_each = try(rule.value.match_blob_index_tags, {})
        content {
          name      = try(match_blob_index_tags.value.name, null)
          value     = try(match_blob_index_tags.value.value, null)
          operation = try(match_blob_index_tags.value.operation, null)
        }
      }
actions {
  dynamic "base_blob" {
    for_each = try(rule.value.actions.base_blob, {})
    content {
      tier_to_cool_after_days_since_modification_greater_than = try(base_blob.value.tier_to_cool_after_days_since_modification_greater_than, null)
      tier_to_archive_after_days_since_modification_greater_than = try(base_blob.value.tier_to_archive_after_days_since_modification_greater_than, null)
      delete_after_days_since_modification_greater_than = try(base_blob.value.delete_after_days_since_modification_greater_than, null)
    }
  }
  dynamic "snapshot" {
    for_each = try(rule.value.actions.snapshot, {})
    content {
      delete_after_days_since_creation_greater_than = try(snapshot.value.delete_after_days_since_creation_greater_than, null)
    }
  }
  dynamic "version" {
    for_each = try(rule.value.actions.version, {})

    content {
      change_tier_to_archive_after_days_since_creation = try(version.value.change_tier_to_archive_after_days_since_creation, null)
      change_tier_to_cool_after_days_since_creation = try(version.value.change_tier_to_cool_after_days_since_creation, null)
      delete_after_days_since_creation = try(version.value.delete_after_days_since_creation, null)
    }
  }
}
    }
  }

}

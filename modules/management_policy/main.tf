locals {
  # Map snake_case Terraform variable shapes to the ARM camelCase contract.
  arm_rules = [
    for k, r in var.rules : {
      name    = r.name
      enabled = r.enabled
      type    = "Lifecycle"
      definition = {
        actions = {
          baseBlob = r.actions.base_blob == null ? null : {
            enableAutoTierToHotFromCool = r.actions.base_blob.auto_tier_to_hot_from_cool_enabled
            tierToCool = (
              r.actions.base_blob.tier_to_cool_after_days_since_creation_greater_than == null &&
              r.actions.base_blob.tier_to_cool_after_days_since_last_access_time_greater_than == null &&
              r.actions.base_blob.tier_to_cool_after_days_since_modification_greater_than == null
              ) ? null : {
              daysAfterCreationGreaterThan       = r.actions.base_blob.tier_to_cool_after_days_since_creation_greater_than
              daysAfterLastAccessTimeGreaterThan = r.actions.base_blob.tier_to_cool_after_days_since_last_access_time_greater_than
              daysAfterModificationGreaterThan   = r.actions.base_blob.tier_to_cool_after_days_since_modification_greater_than
            }
            tierToCold = (
              r.actions.base_blob.tier_to_cold_after_days_since_creation_greater_than == null &&
              r.actions.base_blob.tier_to_cold_after_days_since_last_access_time_greater_than == null &&
              r.actions.base_blob.tier_to_cold_after_days_since_modification_greater_than == null
              ) ? null : {
              daysAfterCreationGreaterThan       = r.actions.base_blob.tier_to_cold_after_days_since_creation_greater_than
              daysAfterLastAccessTimeGreaterThan = r.actions.base_blob.tier_to_cold_after_days_since_last_access_time_greater_than
              daysAfterModificationGreaterThan   = r.actions.base_blob.tier_to_cold_after_days_since_modification_greater_than
            }
            tierToArchive = (
              r.actions.base_blob.tier_to_archive_after_days_since_creation_greater_than == null &&
              r.actions.base_blob.tier_to_archive_after_days_since_last_access_time_greater_than == null &&
              r.actions.base_blob.tier_to_archive_after_days_since_modification_greater_than == null &&
              r.actions.base_blob.tier_to_archive_after_days_since_last_tier_change_greater_than == null
              ) ? null : {
              daysAfterCreationGreaterThan       = r.actions.base_blob.tier_to_archive_after_days_since_creation_greater_than
              daysAfterLastAccessTimeGreaterThan = r.actions.base_blob.tier_to_archive_after_days_since_last_access_time_greater_than
              daysAfterModificationGreaterThan   = r.actions.base_blob.tier_to_archive_after_days_since_modification_greater_than
              daysAfterLastTierChangeGreaterThan = r.actions.base_blob.tier_to_archive_after_days_since_last_tier_change_greater_than
            }
            delete = (
              r.actions.base_blob.delete_after_days_since_creation_greater_than == null &&
              r.actions.base_blob.delete_after_days_since_last_access_time_greater_than == null &&
              r.actions.base_blob.delete_after_days_since_modification_greater_than == null
              ) ? null : {
              daysAfterCreationGreaterThan       = r.actions.base_blob.delete_after_days_since_creation_greater_than
              daysAfterLastAccessTimeGreaterThan = r.actions.base_blob.delete_after_days_since_last_access_time_greater_than
              daysAfterModificationGreaterThan   = r.actions.base_blob.delete_after_days_since_modification_greater_than
            }
          }

          snapshot = r.actions.snapshot == null ? null : {
            tierToCool = r.actions.snapshot.change_tier_to_cool_after_days_since_creation == null ? null : {
              daysAfterCreationGreaterThan = r.actions.snapshot.change_tier_to_cool_after_days_since_creation
            }
            tierToCold = r.actions.snapshot.tier_to_cold_after_days_since_creation_greater_than == null ? null : {
              daysAfterCreationGreaterThan = r.actions.snapshot.tier_to_cold_after_days_since_creation_greater_than
            }
            tierToArchive = (
              r.actions.snapshot.change_tier_to_archive_after_days_since_creation == null &&
              r.actions.snapshot.tier_to_archive_after_days_since_last_tier_change_greater_than == null
              ) ? null : {
              daysAfterCreationGreaterThan       = r.actions.snapshot.change_tier_to_archive_after_days_since_creation
              daysAfterLastTierChangeGreaterThan = r.actions.snapshot.tier_to_archive_after_days_since_last_tier_change_greater_than
            }
            delete = r.actions.snapshot.delete_after_days_since_creation_greater_than == null ? null : {
              daysAfterCreationGreaterThan = r.actions.snapshot.delete_after_days_since_creation_greater_than
            }
          }

          version = r.actions.version == null ? null : {
            tierToCool = r.actions.version.change_tier_to_cool_after_days_since_creation == null ? null : {
              daysAfterCreationGreaterThan = r.actions.version.change_tier_to_cool_after_days_since_creation
            }
            tierToCold = r.actions.version.tier_to_cold_after_days_since_creation_greater_than == null ? null : {
              daysAfterCreationGreaterThan = r.actions.version.tier_to_cold_after_days_since_creation_greater_than
            }
            tierToArchive = (
              r.actions.version.change_tier_to_archive_after_days_since_creation == null &&
              r.actions.version.tier_to_archive_after_days_since_last_tier_change_greater_than == null
              ) ? null : {
              daysAfterCreationGreaterThan       = r.actions.version.change_tier_to_archive_after_days_since_creation
              daysAfterLastTierChangeGreaterThan = r.actions.version.tier_to_archive_after_days_since_last_tier_change_greater_than
            }
            delete = r.actions.version.delete_after_days_since_creation == null ? null : {
              daysAfterCreationGreaterThan = r.actions.version.delete_after_days_since_creation
            }
          }
        }

        filters = {
          blobTypes   = tolist(r.filters.blob_types)
          prefixMatch = r.filters.prefix_match == null ? null : tolist(r.filters.prefix_match)
          blobIndexMatch = r.filters.match_blob_index_tag == null ? null : [
            for t in r.filters.match_blob_index_tag : {
              name  = t.name
              op    = t.operation == null ? "==" : t.operation
              value = t.value
            }
          ]
        }
      }
    }
  ]
  tracing_headers = var.tracing_tags_header == null ? null : { "User-Agent" = var.tracing_tags_header }
}

resource "azapi_resource" "this" {
  name      = "default"
  parent_id = var.storage_account_id
  type      = "Microsoft.Storage/storageAccounts/managementPolicies@2024-01-01"
  body = {
    properties = {
      policy = {
        rules = local.arm_rules
      }
    }
  }
  create_headers         = local.tracing_headers
  delete_headers         = local.tracing_headers
  read_headers           = local.tracing_headers
  response_export_values = []
  retry                  = var.retry
  update_headers         = local.tracing_headers

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }
}

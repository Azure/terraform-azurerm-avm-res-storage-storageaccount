locals {
  tracing_headers = var.tracing_tags_header == null ? null : { "User-Agent" = var.tracing_tags_header }

  signed_identifiers_body = var.signed_identifiers == null ? null : [
    for si in var.signed_identifiers : {
      id = si.id
      accessPolicy = si.access_policy == null ? null : {
        expiryTime = si.access_policy.expiry_time
        permission = si.access_policy.permission
        startTime  = si.access_policy.start_time
      }
    }
  ]
}

resource "azapi_resource" "this" {
  type      = "Microsoft.Storage/storageAccounts/fileServices/shares@2024-01-01"
  name      = var.name
  parent_id = "${var.storage_account_id}/fileServices/default"

  body = {
    properties = {
      accessTier        = var.access_tier
      enabledProtocols  = var.enabled_protocol
      metadata          = var.metadata
      shareQuota        = var.quota
      rootSquash        = var.root_squash
      signedIdentifiers = local.signed_identifiers_body
    }
  }

  schema_validation_enabled = false

  create_headers = local.tracing_headers
  delete_headers = local.tracing_headers
  read_headers   = local.tracing_headers
  update_headers = local.tracing_headers

  retry = var.retry

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]

    content {
      create = timeouts.value.create
      read   = timeouts.value.read
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }

  lifecycle {
    ignore_changes = [body.properties.metadata]
  }
}

module "role_assignments" {
  source = "../role_assignments"

  scope               = azapi_resource.this.id
  role_assignments    = var.role_assignments
  retry               = var.retry
  timeouts            = var.timeouts
  tracing_tags_header = var.tracing_tags_header
}

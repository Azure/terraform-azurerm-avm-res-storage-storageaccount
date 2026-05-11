locals {
  signed_identifiers_body = var.signed_identifiers == null ? [] : [
    for si in var.signed_identifiers : {
      id = si.id
      accessPolicy = si.access_policy == null ? null : {
        expiryTime = si.access_policy.expiry_time
        permission = si.access_policy.permission
        startTime  = si.access_policy.start_time
      }
    }
  ]
  tracing_headers = var.tracing_tags_header == null ? null : { "User-Agent" = var.tracing_tags_header }
}

resource "azapi_resource" "this" {
  name      = var.name
  parent_id = "${var.storage_account_id}/tableServices/default"
  type      = "Microsoft.Storage/storageAccounts/tableServices/tables@2024-01-01"
  body = {
    properties = {
      signedIdentifiers = local.signed_identifiers_body
    }
  }
  create_headers            = local.tracing_headers
  delete_headers            = local.tracing_headers
  read_headers              = local.tracing_headers
  response_export_values    = []
  retry                     = var.retry
  schema_validation_enabled = false
  update_headers            = local.tracing_headers

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

module "role_assignments" {
  # tflint-ignore: required_module_source_tffr1 # relative source is intentional: this is an in-module composition of the role_assignments submodule
  source = "../role_assignments"

  scope               = azapi_resource.this.id
  retry               = var.retry
  role_assignments    = var.role_assignments
  timeouts            = var.timeouts
  tracing_tags_header = var.tracing_tags_header
}

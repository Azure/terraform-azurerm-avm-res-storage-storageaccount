resource "azapi_resource" "this" {
  name      = var.name
  parent_id = "${var.storage_account_id}/fileServices/default"
  type      = "Microsoft.Storage/storageAccounts/fileServices/shares@2025-06-01"
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
  create_headers            = local.tracing_headers
  delete_headers            = local.tracing_headers
  ignore_null_property      = true
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

  lifecycle {
    ignore_changes = [body.properties.metadata]
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

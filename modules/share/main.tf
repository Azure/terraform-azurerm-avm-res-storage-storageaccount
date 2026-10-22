resource "azapi_resource" "this" {
  name      = var.name
  parent_id = "${var.storage_account_id}/fileServices/default"
  type      = var.resource_type
  body = {
    properties = {
      accessTier                = var.access_tier
      enabledProtocols          = var.enabled_protocol
      metadata                  = var.metadata
      shareQuota                = var.quota
      provisionedBandwidthMibps = var.provisioned_bandwidth_mibps
      provisionedIops           = var.provisioned_iops
      rootSquash                = var.root_squash
      signedIdentifiers         = local.signed_identifiers_body
    }
  }
  ignore_null_property      = true
  response_export_values    = []
  retry                     = var.retry
  schema_validation_enabled = false

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
  source = "../role_assignments"

  location                                  = var.location
  scope                                     = azapi_resource.this.id
  retry                                     = var.retry
  role_assignment_definition_lookup_enabled = var.role_assignment_definition_lookup_enabled
  role_assignments                          = var.role_assignments
  timeouts                                  = var.timeouts
}

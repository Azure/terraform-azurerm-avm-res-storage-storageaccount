resource "azapi_update_resource" "this" {
  resource_id    = "${var.storage_account_id}/tableServices/default"
  type           = var.resource_type
  body           = local.resource_body
  read_headers   = local.tracing_headers
  retry          = var.retry
  update_headers = local.tracing_headers

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]

    content {
      create = timeouts.value.create
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }

  lifecycle {
    # The ARM GET on tableServices/default does not faithfully echo back the
    # corsRules that were PATCHed, which causes the next plan/refresh to see
    # perpetual drift on body.properties.cors even though the PATCH succeeded.
    # Ignore changes on this path so the configured CORS is applied on create
    # but subsequent refresh drift on the read-back is suppressed. Updates to
    # cors_rules will require tainting/replacing this resource.
    ignore_changes = [body.properties.cors]
  }
}

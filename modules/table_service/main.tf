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
}

# The ARM GET on tableServices/default is eventually consistent: immediately
# after a successful PATCH the read can return without the corsRules that were
# just applied, which makes a follow-up plan see perpetual drift on
# body.properties.cors. In practice the read-back stabilises after roughly two
# minutes, so wait `var.cors_propagation_wait` before allowing dependents (and
# the post-apply idempotency plan) to refresh state.
resource "time_sleep" "cors_propagation" {
  create_duration = var.cors_propagation_wait
  triggers = {
    cors_rules = jsonencode(try(var.table_properties.cors_rules, null))
    patched_id = azapi_update_resource.this.id
  }
}

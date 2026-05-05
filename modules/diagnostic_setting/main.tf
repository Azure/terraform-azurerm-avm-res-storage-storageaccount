locals {
  tracing_headers = var.tracing_tags_header == null ? null : { "User-Agent" = var.tracing_tags_header }

  # Compose the logs[] array. Each entry has either category or categoryGroup.
  log_entries = concat(
    [for c in var.log_categories : { category = c, enabled = true }],
    [for g in var.log_groups : { categoryGroup = g, enabled = true }],
  )

  metric_entries = [for m in var.metric_categories : { category = m, enabled = true }]
}

resource "azapi_resource" "this" {
  type      = "Microsoft.Insights/diagnosticSettings@2021-05-01-preview"
  name      = var.name
  parent_id = var.target_resource_id

  body = {
    properties = {
      workspaceId                 = var.workspace_resource_id
      storageAccountId            = var.storage_account_resource_id
      eventHubAuthorizationRuleId = var.event_hub_authorization_rule_resource_id
      eventHubName                = var.event_hub_name
      marketplacePartnerId        = var.marketplace_partner_resource_id
      logAnalyticsDestinationType = var.log_analytics_destination_type
      logs                        = length(local.log_entries) == 0 ? null : local.log_entries
      metrics                     = length(local.metric_entries) == 0 ? null : local.metric_entries
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
    ignore_changes = [body.properties.logAnalyticsDestinationType]
  }
}

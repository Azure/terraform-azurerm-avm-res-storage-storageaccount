resource "azapi_resource" "this" {
  location  = var.location
  name      = var.name
  parent_id = var.parent_id
  type      = var.resource_type
  body = {
    properties = {
      subnet = {
        id = var.subnet_resource_id
      }
      customNetworkInterfaceName = var.network_interface_name
      privateLinkServiceConnections = [
        {
          name = var.private_service_connection_name == null ? "pse-${var.name}" : var.private_service_connection_name
          properties = {
            privateLinkServiceId = var.private_connection_resource_id
            groupIds             = [var.subresource_name]
          }
        }
      ]
      ipConfigurations          = local.ip_configurations_body
      applicationSecurityGroups = local.asg_body
    }
  }
  create_headers         = local.tracing_headers
  delete_headers         = local.tracing_headers
  read_headers           = local.tracing_headers
  response_export_values = []
  retry                  = var.retry
  tags                   = var.tags
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

# Optional managed private DNS zone group.
resource "azapi_resource" "private_dns_zone_group" {
  count = var.manage_dns_zone_group && length(var.private_dns_zone_resource_ids) > 0 ? 1 : 0

  name      = var.private_dns_zone_group_name
  parent_id = azapi_resource.this.id
  type      = var.dns_zone_group_resource_type
  body = {
    properties = {
      privateDnsZoneConfigs = [
        for idx, zid in tolist(var.private_dns_zone_resource_ids) : {
          name = "config-${idx}"
          properties = {
            privateDnsZoneId = zid
          }
        }
      ]
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

# Optional lock on the private endpoint.
resource "azapi_resource" "lock" {
  count = var.lock != null ? 1 : 0

  name      = coalesce(var.lock.name, "lock-${var.name}")
  parent_id = azapi_resource.this.id
  type      = var.lock_resource_type
  body = {
    properties = {
      level = var.lock.kind
      notes = var.lock.kind == "CanNotDelete" ? "Cannot delete the resource or its child resources." : "Cannot delete or modify the resource or its child resources."
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

module "role_assignments" {
  # tflint-ignore: required_module_source_tffr1 # relative source is intentional: this is an in-module composition of the role_assignments submodule
  source = "../role_assignments"

  scope                                     = azapi_resource.this.id
  retry                                     = var.retry
  role_assignment_definition_lookup_enabled = var.role_assignment_definition_lookup_enabled
  role_assignments                          = var.role_assignments
  timeouts                                  = var.timeouts
  tracing_tags_header                       = var.tracing_tags_header
}

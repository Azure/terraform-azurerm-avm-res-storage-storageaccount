locals {
  tracing_headers = var.tracing_tags_header == null ? null : { "User-Agent" = var.tracing_tags_header }

  ip_configurations_body = [
    for k, v in var.ip_configurations : {
      name = v.name
      properties = {
        groupId          = var.subresource_name
        memberName       = var.subresource_name
        privateIPAddress = v.private_ip_address
      }
    }
  ]

  asg_body = [
    for k, v in var.application_security_group_resource_ids : { id = v }
  ]
}

resource "azapi_resource" "this" {
  type      = "Microsoft.Network/privateEndpoints@2024-05-01"
  name      = var.name
  parent_id = var.parent_id
  location  = var.location
  tags      = var.tags

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
      ipConfigurations          = length(local.ip_configurations_body) == 0 ? null : local.ip_configurations_body
      applicationSecurityGroups = length(local.asg_body) == 0 ? null : local.asg_body
    }
  }

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
}

# Optional managed private DNS zone group.
resource "azapi_resource" "private_dns_zone_group" {
  count = var.manage_dns_zone_group && length(var.private_dns_zone_resource_ids) > 0 ? 1 : 0

  type      = "Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2024-05-01"
  name      = var.private_dns_zone_group_name
  parent_id = azapi_resource.this.id

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
}

# Optional lock on the private endpoint.
resource "azapi_resource" "lock" {
  count = var.lock != null ? 1 : 0

  type      = "Microsoft.Authorization/locks@2020-05-01"
  name      = coalesce(var.lock.name, "lock-${var.name}")
  parent_id = azapi_resource.this.id

  body = {
    properties = {
      level = var.lock.kind
      notes = var.lock.kind == "CanNotDelete" ? "Cannot delete the resource or its child resources." : "Cannot delete or modify the resource or its child resources."
    }
  }

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
}

module "role_assignments" {
  source = "../role_assignments"

  scope               = azapi_resource.this.id
  role_assignments    = var.role_assignments
  retry               = var.retry
  timeouts            = var.timeouts
  tracing_tags_header = var.tracing_tags_header
}

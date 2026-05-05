module "private_endpoints" {
  source   = "./modules/private_endpoint"
  for_each = var.private_endpoints

  name                                    = each.value.name != null ? each.value.name : "pe-${var.name}"
  parent_id                               = each.value.parent_id != null ? each.value.parent_id : var.parent_id
  location                                = each.value.location != null ? each.value.location : var.location
  tags                                    = each.value.tags
  subnet_resource_id                      = each.value.subnet_resource_id
  subresource_name                        = each.value.subresource_name
  private_connection_resource_id          = azapi_resource.this.id
  private_service_connection_name         = each.value.private_service_connection_name
  network_interface_name                  = each.value.network_interface_name
  ip_configurations                       = each.value.ip_configurations
  application_security_group_resource_ids = each.value.application_security_group_associations

  manage_dns_zone_group         = var.private_endpoints_manage_dns_zone_group
  private_dns_zone_group_name   = each.value.private_dns_zone_group_name
  private_dns_zone_resource_ids = each.value.private_dns_zone_resource_ids

  lock             = each.value.lock
  role_assignments = each.value.role_assignments

  retry               = var.retry
  timeouts            = var.timeouts
  tracing_tags_header = var.enable_telemetry ? local.avm_azapi_header : null
  enable_telemetry    = var.enable_telemetry
}

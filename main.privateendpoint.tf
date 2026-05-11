module "private_endpoints" {
  source   = "./modules/private_endpoint"
  for_each = var.private_endpoints

  location                                  = each.value.location != null ? each.value.location : var.location
  name                                      = each.value.name != null ? each.value.name : "pe-${var.name}"
  parent_id                                 = each.value.resource_group_name != null ? "/subscriptions/${regex("^/subscriptions/([^/]+)/", var.parent_id)[0]}/resourceGroups/${each.value.resource_group_name}" : var.parent_id
  private_connection_resource_id            = azapi_resource.this.id
  subnet_resource_id                        = each.value.subnet_resource_id
  subresource_name                          = each.value.subresource_name
  application_security_group_resource_ids   = each.value.application_security_group_associations
  dns_zone_group_resource_type              = var.resource_types.private_dns_zone_group
  ip_configurations                         = each.value.ip_configurations
  lock                                      = each.value.lock
  lock_resource_type                        = var.resource_types.lock
  manage_dns_zone_group                     = var.private_endpoints_manage_dns_zone_group
  network_interface_name                    = each.value.network_interface_name
  private_dns_zone_group_name               = each.value.private_dns_zone_group_name
  private_dns_zone_resource_ids             = each.value.private_dns_zone_resource_ids
  private_service_connection_name           = each.value.private_service_connection_name
  resource_type                             = var.resource_types.private_endpoint
  retry                                     = var.retry
  role_assignment_definition_lookup_enabled = var.role_assignment_definition_lookup_enabled
  role_assignments                          = each.value.role_assignments
  tags                                      = each.value.tags
  timeouts                                  = var.timeouts
  tracing_tags_header                       = var.enable_telemetry ? local.avm_azapi_header : null
}

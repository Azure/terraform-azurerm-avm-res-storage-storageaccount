resource "azurerm_private_endpoint" "this" {
  for_each = var.new_private_endpoint == null ? toset([]) : local.private_endpoints

  location            = azurerm_storage_account.this.location
  name                = "${each.value}_${azurerm_storage_account.this.name}"
  resource_group_name = coalesce(var.new_private_endpoint.resource_group_name, azurerm_storage_account.this.resource_group_name)
  subnet_id           = var.new_private_endpoint.subnet_id
  tags                = var.new_private_endpoint.tags

  private_service_connection {
    is_manual_connection           = false
    name                           = "${var.new_private_endpoint.private_service_connection.name_prefix}${each.value}"
    private_connection_resource_id = azurerm_storage_account.this.id
    subresource_names              = [each.value]
  }
  dynamic "timeouts" {
    for_each = var.new_private_endpoint.timeouts == null ? [] : [var.new_private_endpoint.timeouts]
    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }

  depends_on = [
    azurerm_storage_table.this,
    azurerm_storage_queue.this,
    azurerm_storage_container.this,
    data.azurerm_private_dns_zone_virtual_network_link.private_link,
    data.azurerm_private_dns_zone_virtual_network_link.public_endpoint,
  ]
}

data "azurerm_private_dns_zone_virtual_network_link" "private_link" {
  for_each = local.private_endpoints

  name                  = var.private_dns_zones_for_private_link[each.value].virtual_network_link_name
  private_dns_zone_name = var.private_dns_zones_for_private_link[each.value].name
  resource_group_name   = var.private_dns_zones_for_private_link[each.value].resource_group_name
}

data "azurerm_private_dns_zone_virtual_network_link" "public_endpoint" {
  for_each = local.private_endpoints

  name                  = var.private_dns_zones_for_public_endpoint[each.value].virtual_network_link_name
  private_dns_zone_name = var.private_dns_zones_for_public_endpoint[each.value].name
  resource_group_name   = var.private_dns_zones_for_public_endpoint[each.value].resource_group_name
}

data "azurerm_private_dns_zone" "private_link" {
  for_each = local.private_endpoints

  name                = var.private_dns_zones_for_private_link[each.value].name
  resource_group_name = var.private_dns_zones_for_private_link[each.value].resource_group_name
}

data "azurerm_private_dns_zone" "public_endpoint" {
  for_each = local.private_endpoints

  name                = var.private_dns_zones_for_public_endpoint[each.value].name
  resource_group_name = var.private_dns_zones_for_public_endpoint[each.value].resource_group_name
}

resource "azurerm_private_dns_a_record" "private" {
  for_each = local.private_endpoints

  name                = azurerm_storage_account.this.name
  records             = [azurerm_private_endpoint.this[each.value].private_service_connection[0].private_ip_address]
  resource_group_name = data.azurerm_private_dns_zone.private_link[each.value].resource_group_name
  ttl                 = var.private_dns_zone_record_ttl
  zone_name           = data.azurerm_private_dns_zone.private_link[each.value].name
  tags                = var.private_dns_zone_record_tags
}

resource "azurerm_private_dns_cname_record" "public" {
  for_each = local.private_endpoints

  name                = azurerm_storage_account.this.name
  record              = azurerm_private_dns_a_record.private[each.key].fqdn
  resource_group_name = azurerm_private_dns_a_record.private[each.key].resource_group_name
  ttl                 = var.private_dns_zone_record_ttl
  zone_name           = data.azurerm_private_dns_zone.public_endpoint[each.value].name
  tags                = var.private_dns_zone_record_tags
}
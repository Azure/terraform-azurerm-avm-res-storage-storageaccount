# Unit tests for private endpoint Edge Zone propagation and request shaping.
mock_provider "azapi" {}
mock_provider "modtm" {}
mock_provider "random" {}

variables {
  location                 = "australiaeast"
  name                     = "stunittest001"
  parent_id                = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-unit-test"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

run "root_edge_zone_propagates_to_private_endpoint" {
  command = plan

  variables {
    edge_zone = "perth"
    private_endpoints = {
      inherited = {
        subnet_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet-edge/subnets/snet-private-endpoints"
        subresource_name   = "blob"
      }
    }
  }

  assert {
    condition = module.private_endpoints["inherited"].extended_location == {
      name = "perth"
      type = "EdgeZone"
    }
    error_message = "Expected the private endpoint request to inherit the storage account Edge Zone."
  }

  # Azure rejects an endpoint placed differently from its account with
  # VnetSpanningForEdgeZonesNotEnabled, so pin the two together.
  assert {
    condition     = azapi_resource.this.body.extendedLocation == module.private_endpoints["inherited"].extended_location
    error_message = "Expected the storage account and its private endpoint to share one Edge Zone placement."
  }
}

run "regional_private_endpoint_omits_extended_location" {
  command = plan

  module {
    source = "./modules/private_endpoint"
  }

  variables {
    location                                  = "australiaeast"
    name                                      = "pe-regional"
    parent_id                                 = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-unit-test"
    private_connection_resource_id            = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-unit-test/providers/Microsoft.Storage/storageAccounts/stunittest001"
    subnet_resource_id                        = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet-regional/subnets/snet-private-endpoints"
    subresource_name                          = "blob"
    role_assignment_definition_lookup_enabled = false
  }

  assert {
    condition     = !can(azapi_resource.this.body.extendedLocation)
    error_message = "Expected a regional private endpoint request to omit extendedLocation entirely."
  }
}

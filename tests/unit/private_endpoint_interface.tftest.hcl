# Unit tests for the AVM `private_endpoints` interface fields: subresource_name
# validation, ip_configurations.member_name, and lock.notes.
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

# subresource_name is optional in the interface type so the module matches the AVM
# schema, but a storage account exposes several subresources and cannot default one.
run "subresource_name_is_still_required" {
  command = plan

  variables {
    private_endpoints = {
      missing = {
        subnet_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet/subnets/snet-private-endpoints"
        subresource_name   = null
      }
    }
  }

  expect_failures = [var.private_endpoints]
}

run "supplied_subresource_name_is_accepted" {
  command = plan

  variables {
    private_endpoints = {
      supplied = {
        subnet_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet/subnets/snet-private-endpoints"
        subresource_name   = "blob"
      }
    }
  }

  # The plan reaching this point is the proof: validation accepted the value.
  # edge_zone is asserted only because it is known at plan time.
  assert {
    condition     = output.private_endpoints["supplied"].edge_zone == null
    error_message = "Expected a private endpoint with a supplied subresource_name to pass validation and plan."
  }
}

run "member_name_overrides_the_subresource_name" {
  command = plan

  module {
    source = "./modules/private_endpoint"
  }

  variables {
    location                                  = "australiaeast"
    name                                      = "pe-dfs"
    parent_id                                 = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-unit-test"
    private_connection_resource_id            = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-unit-test/providers/Microsoft.Storage/storageAccounts/stunittest001"
    subnet_resource_id                        = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet/subnets/snet-private-endpoints"
    subresource_name                          = "blob"
    role_assignment_definition_lookup_enabled = false
    ip_configurations = {
      overridden = {
        name               = "ipconfig-dfs"
        private_ip_address = "10.0.0.10"
        member_name        = "dfs"
      }
      inherited = {
        name               = "ipconfig-blob"
        private_ip_address = "10.0.0.11"
      }
    }
  }

  # groupId always tracks the subresource; only memberName is overridable.
  assert {
    condition = alltrue([
      for c in azapi_resource.this.body.properties.ipConfigurations :
      c.properties.groupId == "blob"
    ])
    error_message = "Expected every ipConfiguration groupId to stay pinned to the subresource name."
  }

  assert {
    condition = one([
      for c in azapi_resource.this.body.properties.ipConfigurations :
      c.properties.memberName if c.name == "ipconfig-dfs"
    ]) == "dfs"
    error_message = "Expected an explicit member_name to override the subresource name."
  }

  assert {
    condition = one([
      for c in azapi_resource.this.body.properties.ipConfigurations :
      c.properties.memberName if c.name == "ipconfig-blob"
    ]) == "blob"
    error_message = "Expected an omitted member_name to fall back to the subresource name."
  }
}

run "lock_notes_are_honoured" {
  command = plan

  module {
    source = "./modules/private_endpoint"
  }

  variables {
    location                                  = "australiaeast"
    name                                      = "pe-locked"
    parent_id                                 = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-unit-test"
    private_connection_resource_id            = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-unit-test/providers/Microsoft.Storage/storageAccounts/stunittest001"
    subnet_resource_id                        = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet/subnets/snet-private-endpoints"
    subresource_name                          = "blob"
    role_assignment_definition_lookup_enabled = false
    lock = {
      kind  = "CanNotDelete"
      notes = "Retained for the 2025 audit."
    }
  }

  assert {
    condition     = azapi_resource.lock[0].body.properties.notes == "Retained for the 2025 audit."
    error_message = "Expected a caller-supplied lock note to reach the lock request."
  }
}

run "omitted_lock_notes_fall_back_to_the_lock_kind" {
  command = plan

  module {
    source = "./modules/private_endpoint"
  }

  variables {
    location                                  = "australiaeast"
    name                                      = "pe-locked-default"
    parent_id                                 = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-unit-test"
    private_connection_resource_id            = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-unit-test/providers/Microsoft.Storage/storageAccounts/stunittest001"
    subnet_resource_id                        = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet/subnets/snet-private-endpoints"
    subresource_name                          = "blob"
    role_assignment_definition_lookup_enabled = false
    lock = {
      kind = "ReadOnly"
    }
  }

  assert {
    condition     = azapi_resource.lock[0].body.properties.notes == "Cannot delete or modify the resource or its child resources."
    error_message = "Expected an omitted lock note to fall back to the note derived from the lock kind."
  }
}

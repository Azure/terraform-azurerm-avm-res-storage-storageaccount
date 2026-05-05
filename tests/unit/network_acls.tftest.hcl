# Unit tests for network_acls composition.
mock_provider "azapi" {}
mock_provider "modtm" {}
mock_provider "random" {}

variables {
  location                 = "eastus"
  name                     = "stunittest001"
  parent_id                = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-unit-test"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

run "default_no_network_rules" {
  command = plan

  variables {
    network_rules = null
  }

  assert {
    condition     = azapi_resource.this.body.properties.networkAcls == null
    error_message = "Expected networkAcls to be null when network_rules is null"
  }
}

run "default_deny" {
  command = plan

  variables {
    network_rules = {
      bypass         = ["AzureServices"]
      default_action = "Deny"
    }
  }

  assert {
    condition     = azapi_resource.this.body.properties.networkAcls.defaultAction == "Deny"
    error_message = "Expected default-deny network ACL"
  }

  assert {
    condition     = azapi_resource.this.body.properties.networkAcls.bypass == "AzureServices"
    error_message = "Expected bypass == AzureServices"
  }
}

run "bypass_none_emits_string_none" {
  command = plan

  variables {
    network_rules = {
      bypass         = []
      default_action = "Deny"
    }
  }

  assert {
    condition     = azapi_resource.this.body.properties.networkAcls.bypass == "None"
    error_message = "Expected empty bypass list to emit \"None\""
  }
}

run "ip_rules_mapped_to_action_allow" {
  command = plan

  variables {
    network_rules = {
      bypass         = ["AzureServices"]
      default_action = "Deny"
      ip_rules       = ["10.0.0.0/24", "192.168.1.1"]
    }
  }

  assert {
    condition     = length(azapi_resource.this.body.properties.networkAcls.ipRules) == 2
    error_message = "Expected 2 IP rules"
  }

  assert {
    condition     = azapi_resource.this.body.properties.networkAcls.ipRules[0].action == "Allow"
    error_message = "Expected ipRules[*].action == Allow"
  }
}

run "private_link_access_emits_resource_access_rules" {
  command = plan

  variables {
    network_rules = {
      bypass         = ["AzureServices"]
      default_action = "Deny"
      private_link_access = [{
        endpoint_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-x/providers/Microsoft.Synapse/workspaces/ws1"
        endpoint_tenant_id   = "00000000-0000-0000-0000-000000000001"
      }]
    }
  }

  assert {
    condition     = length(azapi_resource.this.body.properties.networkAcls.resourceAccessRules) == 1
    error_message = "Expected 1 resource access rule from private_link_access"
  }

  assert {
    condition     = azapi_resource.this.body.properties.networkAcls.resourceAccessRules[0].tenantId == "00000000-0000-0000-0000-000000000001"
    error_message = "Expected tenantId on resource access rule"
  }
}

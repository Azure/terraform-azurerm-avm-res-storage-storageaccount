# Unit tests for the `fqdn` output.
#
# Regression cover for #377: the output used to string-concatenate a hardcoded
# `core.windows.net`, so every sovereign cloud got a hostname that does not
# resolve. Hostnames now come from `properties.primaryEndpoints`, which Azure
# returns with the DNS suffix of the cloud the account actually lives in.
mock_provider "azapi" {}
mock_provider "modtm" {}
mock_provider "random" {}

variables {
  location                 = "eastus"
  name                     = "stunittest001"
  parent_id                = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-unit-test"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  containers = {
    data = {
      name = "data"
    }
  }
  queues = {
    events = {
      name = "events"
    }
  }
  tables = {
    metrics = {
      name = "metrics"
    }
  }
}

run "fqdn_uses_commercial_suffix" {
  command = plan

  override_resource {
    target          = azapi_resource.this
    override_during = plan
    values = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-unit-test/providers/Microsoft.Storage/storageAccounts/stunittest001"
      output = {
        properties = {
          primaryEndpoints = {
            blob  = "https://stunittest001.blob.core.windows.net/"
            queue = "https://stunittest001.queue.core.windows.net/"
            table = "https://stunittest001.table.core.windows.net/"
          }
        }
      }
    }
  }

  assert {
    condition     = output.fqdn["blob"] == "stunittest001.blob.core.windows.net"
    error_message = "Commercial cloud blob FQDN must be stunittest001.blob.core.windows.net, got ${try(output.fqdn["blob"], "<missing>")}"
  }

  assert {
    condition     = output.fqdn["queue"] == "stunittest001.queue.core.windows.net"
    error_message = "Commercial cloud queue FQDN must be stunittest001.queue.core.windows.net, got ${try(output.fqdn["queue"], "<missing>")}"
  }

  assert {
    condition     = output.fqdn["table"] == "stunittest001.table.core.windows.net"
    error_message = "Commercial cloud table FQDN must be stunittest001.table.core.windows.net, got ${try(output.fqdn["table"], "<missing>")}"
  }
}

run "fqdn_uses_us_government_suffix" {
  command = plan

  override_resource {
    target          = azapi_resource.this
    override_during = plan
    values = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-unit-test/providers/Microsoft.Storage/storageAccounts/stunittest001"
      output = {
        properties = {
          primaryEndpoints = {
            blob  = "https://stunittest001.blob.core.usgovcloudapi.net/"
            queue = "https://stunittest001.queue.core.usgovcloudapi.net/"
            table = "https://stunittest001.table.core.usgovcloudapi.net/"
          }
        }
      }
    }
  }

  assert {
    condition     = output.fqdn["blob"] == "stunittest001.blob.core.usgovcloudapi.net"
    error_message = "US Government blob FQDN must use core.usgovcloudapi.net, got ${try(output.fqdn["blob"], "<missing>")}"
  }

  assert {
    condition     = alltrue([for host in values(output.fqdn) : endswith(host, ".core.usgovcloudapi.net")])
    error_message = "No FQDN may fall back to a hardcoded commercial suffix in Azure US Government"
  }
}

run "fqdn_uses_china_suffix" {
  command = plan

  override_resource {
    target          = azapi_resource.this
    override_during = plan
    values = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-unit-test/providers/Microsoft.Storage/storageAccounts/stunittest001"
      output = {
        properties = {
          primaryEndpoints = {
            blob  = "https://stunittest001.blob.core.chinacloudapi.cn/"
            queue = "https://stunittest001.queue.core.chinacloudapi.cn/"
            table = "https://stunittest001.table.core.chinacloudapi.cn/"
          }
        }
      }
    }
  }

  assert {
    condition     = alltrue([for host in values(output.fqdn) : endswith(host, ".core.chinacloudapi.cn")])
    error_message = "No FQDN may fall back to a hardcoded commercial suffix in Azure China"
  }
}

# A routing preference makes Azure return nested `internetEndpoints` and
# `microsoftEndpoints` objects alongside the flat service keys. Treating those
# as strings is a plan-time error, and they must not leak into `fqdn`.
run "fqdn_ignores_nested_routing_endpoints" {
  command = plan

  variables {
    routing = {
      choice                      = "MicrosoftRouting"
      publish_internet_endpoints  = true
      publish_microsoft_endpoints = true
    }
  }

  override_resource {
    target          = azapi_resource.this
    override_during = plan
    values = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-unit-test/providers/Microsoft.Storage/storageAccounts/stunittest001"
      output = {
        properties = {
          primaryEndpoints = {
            blob  = "https://stunittest001.blob.core.usgovcloudapi.net/"
            queue = "https://stunittest001.queue.core.usgovcloudapi.net/"
            table = "https://stunittest001.table.core.usgovcloudapi.net/"
            internetEndpoints = {
              blob = "https://stunittest001-internet.blob.core.usgovcloudapi.net/"
            }
            microsoftEndpoints = {
              blob = "https://stunittest001-microsoft.blob.core.usgovcloudapi.net/"
            }
          }
        }
      }
    }
  }

  assert {
    condition     = output.fqdn["blob"] == "stunittest001.blob.core.usgovcloudapi.net"
    error_message = "Nested routing endpoints must not displace the flat blob endpoint"
  }

  assert {
    condition     = toset(keys(output.fqdn)) == toset(["blob", "queue", "table"])
    error_message = "internetEndpoints/microsoftEndpoints must not appear as fqdn keys, got ${join(", ", keys(output.fqdn))}"
  }
}

# The output is keyed off declared sub-resources, not off everything Azure
# returns. Keeping that contract is what makes this a non-breaking fix.
run "fqdn_keys_track_declared_subresources" {
  command = plan

  variables {
    queues = {}
    tables = {}
  }

  override_resource {
    target          = azapi_resource.this
    override_during = plan
    values = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-unit-test/providers/Microsoft.Storage/storageAccounts/stunittest001"
      output = {
        properties = {
          primaryEndpoints = {
            blob  = "https://stunittest001.blob.core.usgovcloudapi.net/"
            dfs   = "https://stunittest001.dfs.core.usgovcloudapi.net/"
            file  = "https://stunittest001.file.core.usgovcloudapi.net/"
            queue = "https://stunittest001.queue.core.usgovcloudapi.net/"
            table = "https://stunittest001.table.core.usgovcloudapi.net/"
            web   = "https://stunittest001.web.core.usgovcloudapi.net/"
          }
        }
      }
    }
  }

  assert {
    condition     = toset(keys(output.fqdn)) == toset(["blob"])
    error_message = "Only declared sub-resources may appear in fqdn, got ${join(", ", keys(output.fqdn))}"
  }
}

run "fqdn_empty_without_subresources" {
  command = plan

  variables {
    containers = {}
    queues     = {}
    tables     = {}
  }

  assert {
    condition     = length(output.fqdn) == 0
    error_message = "fqdn must stay empty when no containers, queues, or tables are declared"
  }
}

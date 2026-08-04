terraform {
  required_providers {
    azapi = {
      source = "Azure/azapi"
    }
    modtm = {
      source = "Azure/modtm"
    }
    random = {
      source = "hashicorp/random"
    }
  }
}

module "storage" {
  source = "../../../.."

  account_replication_type = "LRS"
  account_tier             = "Standard"
  containers = {
    container = {
      name = "container"
    }
  }
  enable_telemetry = false
  location         = "eastus"
  name             = "ststatemigration"
  parent_id        = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test"
  queues = {
    queue = {
      name = "queue"
    }
  }
  shares = {
    share = {
      name  = "share"
      quota = 1
    }
  }
  tables = {
    table = {
      name = "table"
    }
  }
}

moved {
  from = module.storage.azapi_resource.containers["container"]
  to   = module.storage.module.containers["container"].azapi_resource.this
}

moved {
  from = module.storage.azapi_resource.queue["queue"]
  to   = module.storage.module.queues["queue"].azapi_resource.this
}

moved {
  from = module.storage.azapi_resource.share["share"]
  to   = module.storage.module.shares["share"].azapi_resource.this
}

moved {
  from = module.storage.azapi_resource.table["table"]
  to   = module.storage.module.tables["table"].azapi_resource.this
}

output "resource_ids" {
  value = {
    container = module.storage.containers["container"].id
    queue     = module.storage.queues["queue"].id
    share     = module.storage.shares["share"].id
    table     = module.storage.tables["table"].id
  }
}

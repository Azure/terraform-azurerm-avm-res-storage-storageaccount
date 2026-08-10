mock_provider "azapi" {}
mock_provider "modtm" {}
mock_provider "random" {}

run "create_pre_0_7_state" {
  command   = apply
  state_key = "moved_resources"

  module {
    source = "./tests/fixtures/moved_resources/pre_0_7"
  }
}

run "migrate_each_resource_key" {
  command   = apply
  state_key = "moved_resources"

  module {
    source = "./tests/fixtures/moved_resources/current"
  }

  override_resource {
    target = module.storage.azapi_resource.this
    values = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test/providers/Microsoft.Storage/storageAccounts/ststatemigration"
    }
  }

  assert {
    condition     = output.resource_ids == run.create_pre_0_7_state.resource_ids
    error_message = "Per-key state migration must retain the existing container, queue, share, and table resource IDs."
  }
}

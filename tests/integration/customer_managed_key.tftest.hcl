run "setup" {
  command = apply

  module {
    source = "./tests/fixtures/customer_managed_key"
  }
}

run "create_cmk_account" {
  command = apply

  variables {
    enable_telemetry     = false
    location             = run.setup.location
    parent_id            = run.setup.parent_id
    name                 = run.setup.name
    customer_managed_key = run.setup.customer_managed_key
    managed_identities = {
      user_assigned_resource_ids = [run.setup.identity_id]
    }
  }
}

run "verify_created_account" {
  command = apply

  module {
    source = "./tests/fixtures/customer_managed_key_check"
  }

  variables {
    resource_id = run.create_cmk_account.resource_id
  }

  assert {
    condition     = output.encryption.keySource == "Microsoft.Keyvault" && output.encryption.identity.userAssignedIdentity == run.setup.identity_id
    error_message = "The two-step create must enable CMK with the configured user-assigned identity."
  }
}

run "update_cmk_account" {
  command = apply

  variables {
    enable_telemetry     = false
    location             = run.setup.location
    parent_id            = run.setup.parent_id
    name                 = run.setup.name
    customer_managed_key = run.setup.customer_managed_key
    managed_identities = {
      user_assigned_resource_ids = [run.setup.identity_id]
    }
    tags = {
      regression = "cmk-update"
    }
  }
}

run "verify_updated_account" {
  command = apply

  module {
    source = "./tests/fixtures/customer_managed_key_check"
  }

  variables {
    resource_id = run.update_cmk_account.resource_id
  }

  assert {
    condition     = output.tags.regression == "cmk-update"
    error_message = "The tag change must reach Azure."
  }

  assert {
    condition     = output.encryption.keySource == "Microsoft.Keyvault" && output.encryption.identity.userAssignedIdentity == run.setup.identity_id && output.encryption.keyvaultproperties.keyname == run.setup.customer_managed_key.key_name
    error_message = "Updating the account must preserve the key source, identity, and key."
  }
}

run "update_without_cmk_configuration" {
  command = apply

  variables {
    enable_telemetry = false
    location         = run.setup.location
    parent_id        = run.setup.parent_id
    name             = run.setup.name
    managed_identities = {
      user_assigned_resource_ids = [run.setup.identity_id]
    }
    tags = {
      regression = "cmk-unmanaged"
    }
  }
}

run "verify_unmanaged_key_preserved" {
  command = apply

  module {
    source = "./tests/fixtures/customer_managed_key_check"
  }

  variables {
    resource_id = run.update_without_cmk_configuration.resource_id
  }

  assert {
    condition     = output.tags.regression == "cmk-unmanaged" && output.encryption.keySource == "Microsoft.Keyvault" && output.encryption.identity.userAssignedIdentity == run.setup.identity_id && output.encryption.keyvaultproperties.keyname == run.setup.customer_managed_key.key_name
    error_message = "Removing CMK configuration must update the account without resetting its existing key, even without a follow-up PATCH."
  }
}

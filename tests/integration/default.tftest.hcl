# Integration tests run the module end-to-end against real Azure ARM. The
# tests below complement the example-based smoke tests run by
# `PORCH_NO_TUI=1 ./avm test-examples` by exercising scenarios that combine
# multiple submodules in ways the focused examples do not.
#
# These tests require real Azure credentials and a writeable subscription.
# They are intended for CI-driven runs, not local execution.

variables {
  enable_telemetry = true
}

run "apply_default_example" {
  command = apply

  module {
    source = "./examples/default"
  }
}

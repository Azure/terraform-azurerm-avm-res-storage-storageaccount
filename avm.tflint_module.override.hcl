# Override rules disabled for submodules in this repo.
#
# - required_output_rmfr7: the diagnostic_setting submodule manages a map of
#   azapi_resource instances and exposes resource_ids/resources rather than a
#   single resource_id output, so the AVM single-resource-module output check
#   does not apply.
# - diagnostic_settings: the diagnostic_setting submodule defines its own
#   diagnostic_settings variable (as input, not as a child interface) which is
#   intentionally not the avm-utl-interfaces v0.6.0 schema.
rule "required_output_rmfr7" {
  enabled = false
}

rule "diagnostic_settings" {
  enabled = false
}

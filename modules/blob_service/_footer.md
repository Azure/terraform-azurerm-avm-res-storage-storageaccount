<!-- END_TF_DOCS -->

## Notes

- This submodule is automatically called by the root module when `blob_properties` is configured
- Do not invoke this submodule directly
- Uses `azapi_update_resource` (PATCH semantics) — only the specified properties are updated; unmanaged blob service settings are left unchanged
- See root module documentation for complete usage examples

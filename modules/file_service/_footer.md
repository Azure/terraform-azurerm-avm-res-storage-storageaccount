## Notes

- This submodule is automatically called by the root module when `file_service_properties` is configured.
- Do not invoke this submodule directly — use the root module's `file_service_properties` variable.
- SMB multichannel (`multichannel_enabled`) is only supported on Premium FileStorage accounts.
- The `fileServices/default` resource always exists on a storage account and is patched (not created) using `azapi_update_resource`.
- See the root module documentation and `examples/file_service_properties/` for complete usage examples.
<!-- END_TF_DOCS -->

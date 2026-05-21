## Notes

- This submodule is automatically called by the root module when `table_properties` is configured
- Do not invoke this submodule directly
- Uses `azapi_update_resource` (PATCH) so only the specified properties are modified; all other table service settings remain at their current values
- See root module documentation for complete usage examples

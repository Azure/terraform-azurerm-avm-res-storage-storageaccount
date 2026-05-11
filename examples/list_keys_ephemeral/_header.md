# Ephemeral list keys

Demonstrates how to retrieve storage account access keys from a consuming
configuration using the ephemeral `azapi_resource_action` resource and the
`listKeys` ARM action.

> [!WARNING]
> Key-based authentication is **not recommended**. Prefer Microsoft Entra ID
> (Azure AD) authentication via managed identities or service principals
> wherever supported. This example exists for completeness and for the
> small number of services that do not yet support Entra ID against Azure
> Storage.

The pattern shown here:

* Reads the keys at plan/apply time without ever persisting them in
  Terraform state (ephemeral resources are not written to state).
* Forwards the value to a downstream consumer through a write-only
  attribute (`value_wo` on `azurerm_key_vault_secret`) so the secret is
  also kept out of state.
* Lets the storage account itself remain configured with `shared_access_key_enabled = true`
  for compatibility; flip this to `false` for any deployment that does not
  explicitly need shared-key access.

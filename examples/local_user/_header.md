# Local user (SFTP) example

Deploys a Storage Account with hierarchical namespace enabled, SFTP enabled,
and a Storage Account Local User configured with permission scopes for both
blob containers and file shares. Demonstrates the recommended pattern for
retrieving the local user's generated SSH password via a managed
`azapi_resource_action` invoking the `regeneratePassword` ARM action, and
persisting the password into Key Vault using a write-only attribute
(`value_wo` on `azurerm_key_vault_secret`) so the secret value never enters
Terraform state.

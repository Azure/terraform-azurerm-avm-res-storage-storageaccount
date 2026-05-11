# Customer-managed key vault data source. We need the vault URI for the
# encryption block; the user supplies a vault resource ID.
data "azapi_resource" "customer_managed_key_vault" {
  count = local.customer_managed_key_enabled ? 1 : 0

  resource_id            = var.customer_managed_key.key_vault_resource_id
  type                   = "Microsoft.KeyVault/vaults@2024-11-01"
  response_export_values = ["properties.vaultUri"]
}

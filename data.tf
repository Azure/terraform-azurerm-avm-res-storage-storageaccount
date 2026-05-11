# Customer-managed key vault data source. We need the vault URI for the
# encryption block; the user supplies a vault resource ID.
data "azapi_resource" "customer_managed_key_vault" {
  count = local.customer_managed_key_enabled ? 1 : 0

  resource_id            = var.customer_managed_key.key_vault_resource_id
  type                   = var.resource_types.customer_managed_key_vault
  response_export_values = ["properties.vaultUri"]
}

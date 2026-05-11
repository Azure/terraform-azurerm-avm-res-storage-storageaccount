# State migrations and v1.0.0 removed-resource declarations.
#
# The previous (azurerm-based) implementation used a `removed{}` block for the
# legacy `azurerm_storage_account_network_rules` resource so consumers who had
# it in state could remove it without recreating the storage account. We
# preserve that here.
#
# Additionally, in v1.0.0 we drop the standalone Data Lake Gen2 `paths`
# resource and the singular legacy `storage_data_lake_gen2_filesystem`
# variable. We declare `removed{}` for both so consumers' state is cleaned up
# without recreating data.

removed {
  from = azurerm_storage_account_network_rules.this

  lifecycle {
    destroy = false
  }
}

removed {
  from = azurerm_storage_data_lake_gen2_path.this

  lifecycle {
    destroy = false
  }
}

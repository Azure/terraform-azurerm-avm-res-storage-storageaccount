locals {
  # Effective tier parsed back from the resolved SKU name (strips any V2
  # suffix), so tier-aware logic honours `var.account_sku_name` overrides.
  effective_account_tier = replace(split("_", local.sku_name)[0], "V2", "")
  # SKU name combines tier + replication, with optional V2 suffix when the
  # provisioned billing model V2 is requested (StandardV2_*, PremiumV2_*).
  # When `var.account_sku_name` is supplied it wins over the derived value.
  sku_name = coalesce(var.account_sku_name, var.provisioned_billing_model_version == "V2" ? "${var.account_tier}V2_${var.account_replication_type}" : "${var.account_tier}_${var.account_replication_type}")
}

# Provisioned billing model (V2) example

Deploys a Storage Account using the V2 provisioned billing model by
selecting an explicit `*V2_*` SKU (here `PremiumV2_ZRS` with
`account_kind = "FileStorage"`) and configuring an Azure Files SMB share
with Microsoft Entra ID Kerberos authentication.

> Note: when `account_sku_name` is set explicitly the value is sent to
> Azure verbatim. To derive the V2 SKU automatically from
> `account_tier` / `account_replication_type` instead, leave
> `account_sku_name = null` and set `provisioned_billing_model_version = "V2"`.

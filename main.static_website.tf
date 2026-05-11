# Static website is per-account, but the input is a map for backwards
# compatibility. We pick the first (and only) entry if the map is non-empty.
module "static_website" {
  source   = "./modules/static_website"
  for_each = var.static_website == null ? {} : var.static_website

  storage_account_id = azapi_resource.this.id
  error_404_document = each.value.error_404_document
  index_document     = each.value.index_document
  resource_type      = var.resource_types.blob_service
  retry              = var.retry
  timeouts           = var.timeouts
}

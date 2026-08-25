locals {
  blob_endpoint = length(var.containers) == 0 ? [] : ["blob"]
  endpoints     = toset(concat(local.blob_endpoint, local.queue_endpoint, local.table_endpoint))
  # Azure returns the authoritative endpoint URLs, e.g.
  # "https://mysa.blob.core.usgovcloudapi.net/". A routing preference also adds
  # nested `internetEndpoints`/`microsoftEndpoints` objects to the same map, so
  # keep only the flat string values.
  primary_endpoint_hosts = {
    for service, url in try(azapi_resource.this.output.properties.primaryEndpoints, {}) :
    service => trimsuffix(replace(url, "/^https?:\\/\\//", ""), "/")
    if can(tostring(url))
  }
  queue_endpoint = length(var.queues) == 0 ? [] : ["queue"]
  # Every storage service in a given cloud shares one DNS suffix, so derive it
  # once from any returned host: "mysa.blob.core.usgovcloudapi.net" yields
  # "core.usgovcloudapi.net" once the account and service labels are dropped.
  storage_dns_suffix  = try(join(".", slice(local.storage_host_labels, 2, length(local.storage_host_labels))), "core.windows.net")
  storage_host_labels = try(split(".", values(local.primary_endpoint_hosts)[0]), [])
  table_endpoint      = length(var.tables) == 0 ? [] : ["table"]
}

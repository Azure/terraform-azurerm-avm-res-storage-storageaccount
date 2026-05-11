# Private endpoint with module-managed DNS zone group

Deploys a Storage Account with a private endpoint where this module manages
the private DNS zone group association (`private_endpoints_manage_dns_zone_group = true`,
the default). The example provisions the private DNS zones in the same
configuration and passes their IDs through `private_dns_zone_resource_ids`.

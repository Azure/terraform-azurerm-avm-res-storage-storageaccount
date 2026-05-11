# Private endpoint with externally managed DNS zone group

Deploys a Storage Account with a private endpoint where this module does
not manage the private DNS zone group
(`private_endpoints_manage_dns_zone_group = false`). Use this pattern when
an external system, for example Azure Policy `DINE`, is responsible for
creating the zone group and DNS A records.

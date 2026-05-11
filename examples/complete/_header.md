# Complete example

This deploys the module exercising all of the major sub-resources and
optional features:

- Containers, queues, file shares (with signed identifiers), and tables.
- A user-assigned managed identity plus a system-assigned managed identity.
- Role assignments on the storage account.
- A virtual network with a service endpoint subnet (for `network_rules`)
  and a separate subnet hosting private endpoints for `blob`, `queue`,
  `table`, and `file` (with private DNS zones and VNet links).
- A Log Analytics workspace and diagnostic settings for the storage
  account itself, plus blob, file, queue, and table services.

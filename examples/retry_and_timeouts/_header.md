<!-- BEGIN_TF_DOCS -->
# Retry and timeouts example

This example demonstrates how to configure custom AzAPI retry behaviour and per-operation timeouts on the storage account and its child resources.

The `retry` and `timeouts` inputs flow through to every AzAPI resource managed by the module — root storage account, containers, queues, shares, tables, diagnostic settings, private endpoints, management policy, local users, role assignments, and Data Lake Gen2 filesystems — so any value you supply at the module root applies module-wide. Per-item maps (such as `var.containers["foo"].timeouts`) override the module-level defaults for individual resources.


# Terraform Azure Storage Account Module

This Terraform module is designed to create Azure Storage Accounts and its related resources, including blob containers, queues, tables, and file shares. It also supports the creation of a storage account private endpoint which provides secure and direct connectivity to Azure Storage over a private network.

> [!WARNING]
> Major version Zero (0.y.z) is for initial development. Anything MAY change at any time. A module SHOULD NOT be considered stable till at least it is major version one (1.0.0) or greater. Changes will always be via new versions being published and no changes will be made to existing published versions. For more details please go to <https://semver.org/>

## Features

* Create a storage account with various configuration options such as account kind, tier, replication type, network rules, and identity settings.
* Create blob containers, queues, tables, and file shares within the storage account.
* Support for customer-managed keys for encrypting the data in the storage account.
* Enable private endpoint for the storage account, providing secure access over a private network.

## Limitations

* The storage account name must be globally unique.
* The module creates resources in the same region as the storage account.

> **IMPORTANT** This module manages the Storage Account itself, plus its child containers, queues, tables, file shares, private endpoints and role assignments, through the AzAPI provider, which always authenticates with Microsoft Entra ID and never requires a Storage shared key. We recommend leaving `shared_access_key_enabled = false` (the module default) so that any data-plane access from your own code is also Entra-ID-authenticated. If you also use the [`azurerm` provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs#storage_use_azuread) to manage Storage data-plane resources (for example `azurerm_storage_blob`), set `storage_use_azuread = true` in that provider block. Note that not every Storage service supports Microsoft Entra ID authentication; for those services you will need to enable shared-key access by setting `shared_access_key_enabled = true` on this module.

## Upgrading

### AzAPI provider version

This module requires AzAPI provider version 2.11.0 or later within the 2.x series (`>= 2.11.0, < 3.0.0`). When upgrading to a module release with this requirement, update any AzAPI constraint in your root module that excludes version 2.11.0, then refresh the provider selections recorded in your dependency lock file:

```terraform
terraform {
  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.11"
    }
  }
}
```

```shell
terraform init -upgrade
```

### State migration from v0.6.x

Version 0.7.0 moved containers, queues, shares, and tables from resources in the root module to separate child modules. Terraform cannot automatically move an arbitrary `for_each` key from a resource instance to a module instance. Without an explicit state migration, an upgrade can therefore plan to destroy and recreate these resources.

Before applying an upgrade from v0.6.x, add one `moved` block for each existing resource key to the root module that calls this module. For a module call named `storage`, the migrations for keys named `logs`, `jobs`, `content`, and `metadata` are:

```hcl
moved {
  from = module.storage.azapi_resource.containers["logs"]
  to   = module.storage.module.containers["logs"].azapi_resource.this
}

moved {
  from = module.storage.azapi_resource.queue["jobs"]
  to   = module.storage.module.queues["jobs"].azapi_resource.this
}

moved {
  from = module.storage.azapi_resource.share["content"]
  to   = module.storage.module.shares["content"].azapi_resource.this
}

moved {
  from = module.storage.azapi_resource.table["metadata"]
  to   = module.storage.module.tables["metadata"].azapi_resource.this
}
```

The quoted values are the map keys supplied to the module, which can differ from the Azure resource names. Repeat the relevant block for every key. Replace `module.storage` with the actual module address; for example, include an outer `for_each` key as `module.storage["app"]`.

Run `terraform plan` after adding the moves and do not apply if Terraform still proposes replacing these resources. Keep the `moved` blocks in configuration so the migration is applied consistently to every workspace.

> [!WARNING]
> These moves cover only containers, queues, shares, and tables. Review the complete plan for other changes introduced in v0.7.0, including diagnostic settings and role assignments, before applying the upgrade.

If v0.7.x was already applied or an apply failed partway through, first save a backup and inspect the state:

```shell
terraform state pull > terraform-state-backup.json
terraform state list
```

Terraform state can contain sensitive values. Store the backup securely and delete it when it is no longer needed. A resource may already have the correct address, or it may have the incorrect intermediate address produced by v0.7.x:

```text
module.storage.module.containers.azapi_resource.this["logs"]
```

Move an intermediate address to the configured address before applying:

```shell
terraform state mv 'module.storage.module.containers.azapi_resource.this["logs"]' 'module.storage.module.containers["logs"].azapi_resource.this'
```
Use the equivalent `queues`, `shares`, or `tables` address for the other resource types. Do not run a state move when the destination is already present. A state move only updates Terraform's bookkeeping; it cannot restore an Azure resource or its data if the resource was already deleted.
Use the equivalent `queues`, `shares`, or `tables` address for the other resource types. Do not run a state move when the destination is already present. A state move only updates Terraform's bookkeeping; it cannot restore an Azure resource or its data if the resource was already deleted.

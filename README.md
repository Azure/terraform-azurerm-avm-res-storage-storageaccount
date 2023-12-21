# Terraform Azure Storage Account Module

This Terraform module is designed to create Azure Storage Accounts and its related resources, including blob containers, queues, tables, and file shares. It also supports the creation of a storage account private endpoint which provides secure and direct connectivity to Azure Storage over a private network.

## Features

* Create a storage account with various configuration options such as account kind, tier, replication type, network rules, and identity settings.
* Create blob containers, queues, tables, and file shares within the storage account.
* Support for customer-managed keys for encrypting the data in the storage account.
* Enable private endpoint for the storage account, providing secure access over a private network.

## Limitations

* The storage account name must be globally unique.
* The module creates resources in the same region as the storage account.

## Examples

```hcl
resource "random_pet" "this" {
  length = 1
}

resource "azurerm_resource_group" "this" {
  location = var.location
  name     = "terraform-azurerm-storage-account-${random_pet.this.id}"
}

resource "random_string" "table_acl_id" {
  length  = 64
  special = false
}

resource "azurerm_user_assigned_identity" "this" {
  location            = azurerm_resource_group.this.location
  name                = "storage${random_pet.this.id}"
  resource_group_name = azurerm_resource_group.this.name
}

module "this" {
  source = "../.."

  storage_account_account_replication_type = "LRS"
  storage_account_account_tier             = "Standard"
  storage_account_account_kind             = "StorageV2"
  storage_account_location                 = azurerm_resource_group.this.location
  storage_account_name                     = "tfmodstoracc${random_pet.this.id}"
  storage_account_resource_group_name      = azurerm_resource_group.this.name
  storage_account_min_tls_version          = "TLS1_2"
  storage_account_network_rules = {
    bypass         = ["AzureServices"]
    default_action = "Deny"
    ip_rules       = [local.public_ip]
  }
  storage_account_identity = {
    identity_ids = {
      msi = azurerm_user_assigned_identity.this.id
    }
    type = "UserAssigned"
  }
  storage_account_customer_managed_key = {
    key_name     = azurerm_key_vault_key.storage_key.name
    key_vault_id = azurerm_key_vault.storage_vault.id
  }
  key_vault_access_policy = {
    msi = {
      identity_principle_id = azurerm_user_assigned_identity.this.principal_id
      identity_tenant_id    = azurerm_user_assigned_identity.this.tenant_id
    }
  }
  storage_container = {
    blob_container = {
      name                  = "blob-container-${random_pet.this.id}"
      container_access_type = "private"
    }
  }
  storage_queue = {
    queue0 = {
      name = "queue-${random_pet.this.id}"
    }
  }
  storage_table = {
    table0 = {
      name = "table${random_pet.this.id}"
    }
  }
}
```

Example for private endpoint:

```hcl
resource "random_string" "this" {
  length  = 6
  special = false
  upper   = false
}

resource "azurerm_resource_group" "this" {
  location = var.location
  name     = "terraform-azurerm-storage-account-${random_string.this.result}"
}

resource "azurerm_virtual_network" "vnet" {
  address_space       = ["192.168.0.0/16"]
  location            = azurerm_resource_group.this.location
  name                = "vnet"
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_subnet" "private" {
  address_prefixes     = ["192.168.0.0/24"]
  name                 = "private"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  service_endpoints    = ["Microsoft.Storage"]
}

resource "azurerm_network_security_group" "nsg" {
  location            = azurerm_resource_group.this.location
  name                = "private_nsg"
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_subnet_network_security_group_association" "private" {
  network_security_group_id = azurerm_network_security_group.nsg.id
  subnet_id                 = azurerm_subnet.private.id
}

resource "azurerm_network_security_rule" "no_internet" {
  access                      = "Deny"
  direction                   = "Outbound"
  name                        = "no_internet"
  network_security_group_name = azurerm_network_security_group.nsg.name
  priority                    = 100
  protocol                    = "*"
  resource_group_name         = azurerm_resource_group.this.name
  destination_address_prefix  = "Internet"
  destination_port_range      = "*"
  source_address_prefix       = azurerm_subnet.private.address_prefixes[0]
  source_port_range           = "*"
}

locals {
  endpoints = toset(["blob", "queue", "table"])
}

resource "azurerm_private_dns_zone" "private_links" {
  for_each = local.endpoints

  name                = "privatelink.${each.value}.core.windows.net"
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_private_dns_zone" "public_endpoints" {
  for_each = local.endpoints

  name                = "${each.value}.core.windows.net"
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "private_links" {
  for_each = local.endpoints

  name                  = "${each.value}_${azurerm_virtual_network.vnet.name}_private"
  private_dns_zone_name = azurerm_private_dns_zone.private_links[each.value].name
  resource_group_name   = azurerm_resource_group.this.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}

resource "azurerm_private_dns_zone_virtual_network_link" "public_endpoints" {
  for_each = local.endpoints

  name                  = "${each.value}_${azurerm_virtual_network.vnet.name}_public"
  private_dns_zone_name = azurerm_private_dns_zone.public_endpoints[each.value].name
  resource_group_name   = azurerm_resource_group.this.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}

module "public_ip" {
  count = var.bypass_ip_cidr == null ? 1 : 0

  source  = "lonegunmanb/public-ip/lonegunmanb"
  version = "0.1.0"
}

module "this" {
  #checkov:skip=CKV_AZURE_34:It's a known issue that Checkov cannot work prefect along with module
  #checkov:skip=CKV_AZURE_35:It's a known issue that Checkov cannot work prefect along with module
  #checkov:skip=CKV2_AZURE_20:It's a known issue that Checkov cannot work prefect along with module
  #checkov:skip=CKV2_AZURE_21:It's a known issue that Checkov cannot work prefect along with module
  source = "../.."

  storage_account_account_replication_type = "LRS"
  storage_account_account_tier             = "Standard"
  storage_account_account_kind             = "StorageV2"
  storage_account_location                 = azurerm_resource_group.this.location
  storage_account_name                     = "tfmodstoracc${random_string.this.result}"
  storage_account_resource_group_name      = azurerm_resource_group.this.name
  storage_account_min_tls_version          = "TLS1_2"
  storage_account_network_rules = {
    bypass                     = ["AzureServices"]
    default_action             = "Deny"
    ip_rules                   = [try(module.public_ip[0].public_ip, var.bypass_ip_cidr)]
    virtual_network_subnet_ids = toset([azurerm_subnet.private.id])
  }
  storage_container = {
    blob_container0 = {
      name                  = "blob-container-${random_string.this.result}-0"
      container_access_type = "private"
    }
    blob_container1 = {
      name                  = "blob-container-${random_string.this.result}-1"
      container_access_type = "private"
    }
  }
  storage_queue = {
    queue0 = {
      name = "queue-${random_string.this.result}-0"
    }
    queue1 = {
      name = "queue-${random_string.this.result}-1"
    }
  }
  storage_table = {
    table0 = {
      name = "table${random_string.this.result}0"
    }
    table1 = {
      name = "table${random_string.this.result}1"
    }
  }
  new_private_endpoint = {
    subnet_id = azurerm_subnet.private.id
    private_service_connection = {
      name_prefix = "pe_"
    }
  }
  private_dns_zones_for_private_link = {
    for endpoint in local.endpoints : endpoint => {
      resource_group_name       = azurerm_resource_group.this.name
      name                      = azurerm_private_dns_zone.private_links[endpoint].name
      virtual_network_link_name = azurerm_private_dns_zone_virtual_network_link.private_links[endpoint].name
    }
  }
  private_dns_zones_for_public_endpoint = {
    for endpoint in local.endpoints : endpoint => {
      resource_group_name       = azurerm_resource_group.this.name
      name                      = azurerm_private_dns_zone.public_endpoints[endpoint].name
      virtual_network_link_name = azurerm_private_dns_zone_virtual_network_link.public_endpoints[endpoint].name
    }
  }
}

module "another_container" {
  #checkov:skip=CKV_AZURE_34:It's a known issue that Checkov cannot work prefect along with module
  #checkov:skip=CKV_AZURE_35:It's a known issue that Checkov cannot work prefect along with module
  #checkov:skip=CKV2_AZURE_20:It's a known issue that Checkov cannot work prefect along with module
  #checkov:skip=CKV2_AZURE_21:It's a known issue that Checkov cannot work prefect along with module
  source = "../.."

  storage_account_account_replication_type = "LRS"
  storage_account_account_tier             = "Standard"
  storage_account_account_kind             = "StorageV2"
  storage_account_location                 = azurerm_resource_group.this.location
  storage_account_name                     = "tfmodstoracc${random_string.this.result}2"
  storage_account_resource_group_name      = azurerm_resource_group.this.name
  storage_account_min_tls_version          = "TLS1_2"
  storage_account_network_rules = {
    bypass                     = ["AzureServices"]
    default_action             = "Deny"
    ip_rules                   = [try(module.public_ip[0].public_ip, var.bypass_ip_cidr)]
    virtual_network_subnet_ids = toset([azurerm_subnet.private.id])
  }
  storage_container = {
    blob_container = {
      name                  = "another-blob-container-${random_string.this.result}"
      container_access_type = "private"
    }
  }
  new_private_endpoint = {
    subnet_id = azurerm_subnet.private.id
    private_service_connection = {
      name_prefix = "pe_"
    }
  }
  private_dns_zones_for_private_link = {
    blob = {
      resource_group_name       = azurerm_resource_group.this.name
      name                      = azurerm_private_dns_zone.private_links["blob"].name
      virtual_network_link_name = azurerm_private_dns_zone_virtual_network_link.private_links["blob"].name
    }
  }
  private_dns_zones_for_public_endpoint = {
    blob = {
      resource_group_name       = azurerm_resource_group.this.name
      name                      = azurerm_private_dns_zone.public_endpoints["blob"].name
      virtual_network_link_name = azurerm_private_dns_zone_virtual_network_link.public_endpoints["blob"].name
    }
  }
}
```

## Pre-Commit & Pr-Check & Test

### Configurations

- [Configure Terraform for Azure](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/terraform-install-configure)

We assumed that you have setup service principal's credentials in your environment variables like below:

```shell
export ARM_SUBSCRIPTION_ID="<azure_subscription_id>"
export ARM_TENANT_ID="<azure_subscription_tenant_id>"
export ARM_CLIENT_ID="<service_principal_appid>"
export ARM_CLIENT_SECRET="<service_principal_password>"
```

On Windows Powershell:

```shell
$env:ARM_SUBSCRIPTION_ID="<azure_subscription_id>"
$env:ARM_TENANT_ID="<azure_subscription_tenant_id>"
$env:ARM_CLIENT_ID="<service_principal_appid>"
$env:ARM_CLIENT_SECRET="<service_principal_password>"
```

We provide a docker image to run the pre-commit checks and tests for you: `mcr.microsoft.com/azterraform:latest`

To run the pre-commit task, we can run the following command:

```shell
$ docker run --rm -v $(pwd):/src -w /src mcr.microsoft.com/azterraform:latest make pre-commit
```

On Windows Powershell:

```shell
$ docker run --rm -v ${pwd}:/src -w /src mcr.microsoft.com/azterraform:latest make pre-commit
```

In pre-commit task, we will:

1. Run `terraform fmt -recursive` command for your Terraform code.
2. Run `terrafmt fmt -f` command for markdown files and go code files to ensure that the Terraform code embedded in these files are well formatted.
3. Run `go mod tidy` and `go mod vendor` for test folder to ensure that all the dependencies have been synced.
4. Run `gofmt` for all go code files.
5. Run `gofumpt` for all go code files.
6. Run `terraform-docs` on `README.md` file, then run `markdown-table-formatter` to format markdown tables in `README.md`.

Then we can run the pr-check task to check whether our code meets our pipeline's requirement(We strongly recommend you run the following command before you commit):

```shell
$ docker run --rm -v $(pwd):/src -w /src mcr.microsoft.com/azterraform:latest make pr-check
```

On Windows Powershell:

```shell
$ docker run --rm -v ${pwd}:/src -w /src mcr.microsoft.com/azterraform:latest make pr-check
```

To run the e2e-test, we can run the following command:

```text
docker run --rm -v $(pwd):/src -w /src -e ARM_SUBSCRIPTION_ID -e ARM_TENANT_ID -e ARM_CLIENT_ID -e ARM_CLIENT_SECRET mcr.microsoft.com/azterraform:latest make e2e-test
```

On Windows Powershell:

```text
docker run --rm -v ${pwd}:/src -w /src -e ARM_SUBSCRIPTION_ID -e ARM_TENANT_ID -e ARM_CLIENT_ID -e ARM_CLIENT_SECRET mcr.microsoft.com/azterraform:latest make e2e-test
```

#### Prerequisites

- [Docker](https://www.docker.com/community-edition#/download)

## License

[MIT](LICENSE)

# Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.microsoft.com.

When you submit a pull request, a CLA-bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., label, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.63.0, < 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 3.63.0, < 4.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_key_vault_access_policy.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_access_policy) | resource |
| [azurerm_private_dns_a_record.private](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_a_record) | resource |
| [azurerm_private_dns_cname_record.public](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_cname_record) | resource |
| [azurerm_private_endpoint.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_storage_account.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_storage_account_customer_managed_key.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account_customer_managed_key) | resource |
| [azurerm_storage_account_local_user.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account_local_user) | resource |
| [azurerm_storage_account_network_rules.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account_network_rules) | resource |
| [azurerm_storage_container.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container) | resource |
| [azurerm_storage_queue.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_queue) | resource |
| [azurerm_storage_share.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_share) | resource |
| [azurerm_storage_table.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_table) | resource |
| [azurerm_client_config.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_private_dns_zone.private_link](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/private_dns_zone) | data source |
| [azurerm_private_dns_zone.public_endpoint](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/private_dns_zone) | data source |
| [azurerm_private_dns_zone_virtual_network_link.private_link](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/private_dns_zone_virtual_network_link) | data source |
| [azurerm_private_dns_zone_virtual_network_link.public_endpoint](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/private_dns_zone_virtual_network_link) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_key_vault_access_policy"></a> [key\_vault\_access\_policy](#input\_key\_vault\_access\_policy) | Since storage account's customer managed key might require key vault permission, you can create the corresponding permission by setting this variable.<br><br>- `key_permissions` - (Optional) A map of list of key permissions, key is user assigned identity id, the element in value list must be one or more from the following: `Backup`, `Create`, `Decrypt`, Delete, `Encrypt`, `Get`, `Import`, `List`, `Purge`, `Recover`, `Restore`, `Sign`, `UnwrapKey`, `Update`, `Verify`, `WrapKey`, `Release`, `Rotate`, `GetRotationPolicy` and `SetRotationPolicy`. Defaults to `["Get", "UnwrapKey", "WrapKey"]`<br>- `identity_principle_id` - (Required) The principal ID of managed identity. Changing this forces a new resource to be created.<br>- `identity_tenant_id` - (Required) The tenant ID of managed identity. Changing this forces a new resource to be created.<br><br>---<br>`timeouts` block supports the following:<br>- `create` - (Defaults to 30 minutes) Used when creating the Key Vault Access Policy.<br>- `delete` - (Defaults to 30 minutes) Used when deleting the Key Vault Access Policy.<br>- `read` - (Defaults to 5 minutes) Used when retrieving the Key Vault Access Policy.<br>- `update` - (Defaults to 30 minutes) Used when updating the Key Vault Access Policy. | <pre>map(object({<br>    key_permissions = optional(list(string), [<br>      "Get",<br>      "UnwrapKey",<br>      "WrapKey"<br>    ])<br>    identity_principle_id = string<br>    identity_tenant_id    = string<br>    timeouts = optional(object({<br>      create = optional(string)<br>      delete = optional(string)<br>      read   = optional(string)<br>      update = optional(string)<br>    }))<br>  }))</pre> | `{}` | no |
| <a name="input_new_private_endpoint"></a> [new\_private\_endpoint](#input\_new\_private\_endpoint) | Setting this variable would create corresponding private endpoints and private dns records for storage account service.<br><br>- `resource_group_name` - (Optional) Specifies the Name of the Resource Group within which the Private Endpoint should exist. Defaults to storage account's resource group. Changing this forces a new resource to be created.<br>- `subnet_id` - (Required) The ID of the Subnet from which Private IP Addresses will be allocated for this Private Endpoint. Changing this forces a new resource to be created.<br>- `tags` - (Optional) A mapping of tags to assign to the resource.<br><br>---<br>`private_service_connection` block supports the following:<br>- `name` - (Required) Specifies the Name of the Private Service Connection. Changing this forces a new resource to be created.<br><br>---<br>`timeouts` block supports the following:<br>- `create` - (Defaults to 60 minutes) Used when creating the Private Endpoint.<br>- `delete` - (Defaults to 60 minutes) Used when deleting the Private Endpoint.<br>- `read` - (Defaults to 5 minutes) Used when retrieving the Private Endpoint.<br>- `update` - (Defaults to 60 minutes) Used when updating the Private Endpoint. | <pre>object({<br>    resource_group_name = optional(string)<br>    subnet_id           = string<br>    tags                = optional(map(string))<br>    private_service_connection = object({<br>      name_prefix = string<br>    })<br>    timeouts = optional(object({<br>      create = optional(string)<br>      delete = optional(string)<br>      read   = optional(string)<br>      update = optional(string)<br>    }))<br>  })</pre> | `null` | no |
| <a name="input_private_dns_zone_record_tags"></a> [private\_dns\_zone\_record\_tags](#input\_private\_dns\_zone\_record\_tags) | Tags for private dns zone related resources. | `map(string)` | `{}` | no |
| <a name="input_private_dns_zone_record_ttl"></a> [private\_dns\_zone\_record\_ttl](#input\_private\_dns\_zone\_record\_ttl) | The Time To Live (TTL) of the DNS record in seconds. Defaults to `300`. | `number` | `300` | no |
| <a name="input_private_dns_zones_for_private_link"></a> [private\_dns\_zones\_for\_private\_link](#input\_private\_dns\_zones\_for\_private\_link) | A map of private dns zones that used to create corresponding a records and cname records for the private endpoints, the key is static string for the storage service, like `blob`, `table`, `queue`.<br>- `resource_group_name` - (Required) Specifies the resource group where the resource exists. Changing this forces a new resource to be created.<br>- `name` - (Required) The name of the Private DNS Zone for private link endpoint. Must be a valid domain name, e.g.: `privatelink.blob.core.windows.net`. Changing this forces a new resource to be created.<br>- `virtual_network_link_name` - (Required) The name of the Private DNS Zone Virtual Network Link. | <pre>map(object({<br>    resource_group_name       = string<br>    name                      = string<br>    virtual_network_link_name = string<br>  }))</pre> | `{}` | no |
| <a name="input_private_dns_zones_for_public_endpoint"></a> [private\_dns\_zones\_for\_public\_endpoint](#input\_private\_dns\_zones\_for\_public\_endpoint) | A map of private dns zones that used to create corresponding a records and cname records for the public endpoints, the key is static string for the storage service, like `blob`, `table`, `queue`.<br>- `resource_group_name` - (Required) Specifies the resource group where the resource exists. Changing this forces a new resource to be created.<br>- `name` - (Required) The name of the Private DNS Zone for private link endpoint. Must be a valid domain name, e.g.: `blob.core.windows.net`. Changing this forces a new resource to be created.<br>- `virtual_network_link_name` - (Required) The name of the Private DNS Zone Virtual Network Link. | <pre>map(object({<br>    resource_group_name       = string<br>    name                      = string<br>    virtual_network_link_name = string<br>  }))</pre> | `{}` | no |
| <a name="input_storage_account_access_tier"></a> [storage\_account\_access\_tier](#input\_storage\_account\_access\_tier) | (Optional) Defines the access tier for `BlobStorage`, `FileStorage` and `StorageV2` accounts. Valid options are `Hot` and `Cool`, defaults to `Hot`. | `string` | `null` | no |
| <a name="input_storage_account_account_kind"></a> [storage\_account\_account\_kind](#input\_storage\_account\_account\_kind) | (Optional) Defines the Kind of account. Valid options are `BlobStorage`, `BlockBlobStorage`, `FileStorage`, `Storage` and `StorageV2`. Defaults to `StorageV2`. | `string` | `null` | no |
| <a name="input_storage_account_account_replication_type"></a> [storage\_account\_account\_replication\_type](#input\_storage\_account\_account\_replication\_type) | (Required) Defines the type of replication to use for this storage account. Valid options are `LRS`, `GRS`, `RAGRS`, `ZRS`, `GZRS` and `RAGZRS`. | `string` | n/a | yes |
| <a name="input_storage_account_account_tier"></a> [storage\_account\_account\_tier](#input\_storage\_account\_account\_tier) | (Required) Defines the Tier to use for this storage account. Valid options are `Standard` and `Premium`. For `BlockBlobStorage` and `FileStorage` accounts only `Premium` is valid. Changing this forces a new resource to be created. | `string` | n/a | yes |
| <a name="input_storage_account_allow_nested_items_to_be_public"></a> [storage\_account\_allow\_nested\_items\_to\_be\_public](#input\_storage\_account\_allow\_nested\_items\_to\_be\_public) | (Optional) Allow or disallow nested items within this Account to opt into being public. Defaults to `true`. | `bool` | `null` | no |
| <a name="input_storage_account_allowed_copy_scope"></a> [storage\_account\_allowed\_copy\_scope](#input\_storage\_account\_allowed\_copy\_scope) | (Optional) Restrict copy to and from Storage Accounts within an AAD tenant or with Private Links to the same VNet. Possible values are `AAD` and `PrivateLink`. | `string` | `null` | no |
| <a name="input_storage_account_azure_files_authentication"></a> [storage\_account\_azure\_files\_authentication](#input\_storage\_account\_azure\_files\_authentication) | - `directory_type` - (Required) Specifies the directory service used. Possible values are `AADDS`, `AD` and `AADKERB`.<br><br>---<br>`active_directory` block supports the following:<br>- `domain_guid` - (Required) Specifies the domain GUID.<br>- `domain_name` - (Required) Specifies the primary domain that the AD DNS server is authoritative for.<br>- `domain_sid` - (Required) Specifies the security identifier (SID).<br>- `forest_name` - (Required) Specifies the Active Directory forest.<br>- `netbios_domain_name` - (Required) Specifies the NetBIOS domain name.<br>- `storage_sid` - (Required) Specifies the security identifier (SID) for Azure Storage. | <pre>object({<br>    directory_type = string<br>    active_directory = optional(object({<br>      domain_guid         = string<br>      domain_name         = string<br>      domain_sid          = string<br>      forest_name         = string<br>      netbios_domain_name = string<br>      storage_sid         = string<br>    }))<br>  })</pre> | `null` | no |
| <a name="input_storage_account_blob_properties"></a> [storage\_account\_blob\_properties](#input\_storage\_account\_blob\_properties) | - `change_feed_enabled` - (Optional) Is the blob service properties for change feed events enabled? Default to `false`.<br>- `change_feed_retention_in_days` - (Optional) The duration of change feed events retention in days. The possible values are between 1 and 146000 days (400 years). Setting this to null (or omit this in the configuration file) indicates an infinite retention of the change feed.<br>- `default_service_version` - (Optional) The API Version which should be used by default for requests to the Data Plane API if an incoming request doesn't specify an API Version.<br>- `last_access_time_enabled` - (Optional) Is the last access time based tracking enabled? Default to `false`.<br>- `versioning_enabled` - (Optional) Is versioning enabled? Default to `false`.<br><br>---<br>`container_delete_retention_policy` block supports the following:<br>- `days` - (Optional) Specifies the number of days that the container should be retained, between `1` and `365` days. Defaults to `7`.<br><br>---<br>`cors_rule` block supports the following:<br>- `allowed_headers` - (Required) A list of headers that are allowed to be a part of the cross-origin request.<br>- `allowed_methods` - (Required) A list of HTTP methods that are allowed to be executed by the origin. Valid options are `DELETE`, `GET`, `HEAD`, `MERGE`, `POST`, `OPTIONS`, `PUT` or `PATCH`.<br>- `allowed_origins` - (Required) A list of origin domains that will be allowed by CORS.<br>- `exposed_headers` - (Required) A list of response headers that are exposed to CORS clients.<br>- `max_age_in_seconds` - (Required) The number of seconds the client should cache a preflight response.<br><br>---<br>`delete_retention_policy` block supports the following:<br>- `days` - (Optional) Specifies the number of days that the blob should be retained, between `1` and `365` days. Defaults to `7`.<br><br>---<br>`restore_policy` block supports the following:<br>- `days` - (Required) Specifies the number of days that the blob can be restored, between `1` and `365` days. This must be less than the `days` specified for `delete_retention_policy`. | <pre>object({<br>    change_feed_enabled           = optional(bool)<br>    change_feed_retention_in_days = optional(number)<br>    default_service_version       = optional(string)<br>    last_access_time_enabled      = optional(bool)<br>    versioning_enabled            = optional(bool)<br>    container_delete_retention_policy = optional(object({<br>      days = optional(number)<br>    }))<br>    cors_rule = optional(list(object({<br>      allowed_headers    = list(string)<br>      allowed_methods    = list(string)<br>      allowed_origins    = list(string)<br>      exposed_headers    = list(string)<br>      max_age_in_seconds = number<br>    })))<br>    delete_retention_policy = optional(object({<br>      days = optional(number)<br>    }))<br>    restore_policy = optional(object({<br>      days = number<br>    }))<br>  })</pre> | `null` | no |
| <a name="input_storage_account_cross_tenant_replication_enabled"></a> [storage\_account\_cross\_tenant\_replication\_enabled](#input\_storage\_account\_cross\_tenant\_replication\_enabled) | (Optional) Should cross Tenant replication be enabled? Defaults to `true`. | `bool` | `null` | no |
| <a name="input_storage_account_custom_domain"></a> [storage\_account\_custom\_domain](#input\_storage\_account\_custom\_domain) | - `name` - (Required) The Custom Domain Name to use for the Storage Account, which will be validated by Azure.<br>- `use_subdomain` - (Optional) Should the Custom Domain Name be validated by using indirect CNAME validation? | <pre>object({<br>    name          = string<br>    use_subdomain = optional(bool)<br>  })</pre> | `null` | no |
| <a name="input_storage_account_customer_managed_key"></a> [storage\_account\_customer\_managed\_key](#input\_storage\_account\_customer\_managed\_key) | Note: `var.storage_account_customer_managed_key` can only be set when the `var.storage_account_account_kind` is set to `StorageV2` or `var.storage_account_account_kind_account_tier` set to `Premium`, and the identity type is `UserAssigned`.<br><br>- `key_name` - (Required) The name of Key Vault Key.<br>- `key_vault_id` - (Required) The ID of the Key Vault.<br>- `key_version` - (Optional) The version of Key Vault Key. Remove or omit this argument to enable Automatic Key Rotation.<br><br>---<br>`timeouts` block supports the following:<br>- `create` - (Defaults to 30 minutes) Used when creating the Storage Account Customer Managed Keys.<br>- `delete` - (Defaults to 30 minutes) Used when deleting the Storage Account Customer Managed Keys.<br>- `read` - (Defaults to 5 minutes) Used when retrieving the Storage Account Customer Managed Keys.<br>- `update` - (Defaults to 30 minutes) Used when updating the Storage Account Customer Managed Keys. | <pre>object({<br>    key_name     = string<br>    key_vault_id = string<br>    key_version  = optional(string)<br>    timeouts = optional(object({<br>      create = optional(string)<br>      delete = optional(string)<br>      read   = optional(string)<br>      update = optional(string)<br>    }))<br>  })</pre> | `null` | no |
| <a name="input_storage_account_default_to_oauth_authentication"></a> [storage\_account\_default\_to\_oauth\_authentication](#input\_storage\_account\_default\_to\_oauth\_authentication) | (Optional) Default to Azure Active Directory authorization in the Azure portal when accessing the Storage Account. The default value is `false` | `bool` | `null` | no |
| <a name="input_storage_account_edge_zone"></a> [storage\_account\_edge\_zone](#input\_storage\_account\_edge\_zone) | (Optional) Specifies the Edge Zone within the Azure Region where this Storage Account should exist. Changing this forces a new Storage Account to be created. | `string` | `null` | no |
| <a name="input_storage_account_enable_https_traffic_only"></a> [storage\_account\_enable\_https\_traffic\_only](#input\_storage\_account\_enable\_https\_traffic\_only) | (Optional) Boolean flag which forces HTTPS if enabled, see [here](https://docs.microsoft.com/azure/storage/storage-require-secure-transfer/) for more information. Defaults to `true`. | `bool` | `null` | no |
| <a name="input_storage_account_identity"></a> [storage\_account\_identity](#input\_storage\_account\_identity) | - `identity_ids` - (Optional) Specifies a list of User Assigned Managed Identity IDs to be assigned to this Storage Account.<br>- `type` - (Required) Specifies the type of Managed Service Identity that should be configured on this Storage Account. Possible values are `SystemAssigned`, `UserAssigned`, `SystemAssigned, UserAssigned` (to enable both). | <pre>object({<br>    identity_ids = optional(map(string))<br>    type         = string<br>  })</pre> | `null` | no |
| <a name="input_storage_account_immutability_policy"></a> [storage\_account\_immutability\_policy](#input\_storage\_account\_immutability\_policy) | - `allow_protected_append_writes` - (Required) When enabled, new blocks can be written to an append blob while maintaining immutability protection and compliance. Only new blocks can be added and any existing blocks cannot be modified or deleted.<br>- `period_since_creation_in_days` - (Required) The immutability period for the blobs in the container since the policy creation, in days.<br>- `state` - (Required) Defines the mode of the policy. `Disabled` state disables the policy, `Unlocked` state allows increase and decrease of immutability retention time and also allows toggling allowProtectedAppendWrites property, `Locked` state only allows the increase of the immutability retention time. A policy can only be created in a Disabled or Unlocked state and can be toggled between the two states. Only a policy in an Unlocked state can transition to a Locked state which cannot be reverted. | <pre>object({<br>    allow_protected_append_writes = bool<br>    period_since_creation_in_days = number<br>    state                         = string<br>  })</pre> | `null` | no |
| <a name="input_storage_account_infrastructure_encryption_enabled"></a> [storage\_account\_infrastructure\_encryption\_enabled](#input\_storage\_account\_infrastructure\_encryption\_enabled) | (Optional) Is infrastructure encryption enabled? Changing this forces a new resource to be created. Defaults to `false`. | `bool` | `null` | no |
| <a name="input_storage_account_is_hns_enabled"></a> [storage\_account\_is\_hns\_enabled](#input\_storage\_account\_is\_hns\_enabled) | (Optional) Is Hierarchical Namespace enabled? This can be used with Azure Data Lake Storage Gen 2 ([see here for more information](https://docs.microsoft.com/azure/storage/blobs/data-lake-storage-quickstart-create-account/)). Changing this forces a new resource to be created. | `bool` | `null` | no |
| <a name="input_storage_account_large_file_share_enabled"></a> [storage\_account\_large\_file\_share\_enabled](#input\_storage\_account\_large\_file\_share\_enabled) | (Optional) Is Large File Share Enabled? | `bool` | `null` | no |
| <a name="input_storage_account_local_user"></a> [storage\_account\_local\_user](#input\_storage\_account\_local\_user) | - `home_directory` - (Optional) The home directory of the Storage Account Local User.<br>- `name` - (Required) The name which should be used for this Storage Account Local User. Changing this forces a new Storage Account Local User to be created.<br>- `ssh_key_enabled` - (Optional) Specifies whether SSH Key Authentication is enabled. Defaults to `false`.<br>- `ssh_password_enabled` - (Optional) Specifies whether SSH Password Authentication is enabled. Defaults to `false`.<br><br>---<br>`permission_scope` block supports the following:<br>- `resource_name` - (Required) The container name (when `service` is set to `blob`) or the file share name (when `service` is set to `file`), used by the Storage Account Local User.<br>- `service` - (Required) The storage service used by this Storage Account Local User. Possible values are `blob` and `file`.<br><br>---<br>`permissions` block supports the following:<br>- `create` - (Optional) Specifies if the Local User has the create permission for this scope. Defaults to `false`.<br>- `delete` - (Optional) Specifies if the Local User has the delete permission for this scope. Defaults to `false`.<br>- `list` - (Optional) Specifies if the Local User has the list permission for this scope. Defaults to `false`.<br>- `read` - (Optional) Specifies if the Local User has the read permission for this scope. Defaults to `false`.<br>- `write` - (Optional) Specifies if the Local User has the write permission for this scope. Defaults to `false`.<br><br>---<br>`ssh_authorized_key` block supports the following:<br>- `description` - (Optional) The description of this SSH authorized key.<br>- `key` - (Required) The public key value of this SSH authorized key.<br><br>---<br>`timeouts` block supports the following:<br>- `create` - (Defaults to 30 minutes) Used when creating the Storage Account Local User.<br>- `delete` - (Defaults to 30 minutes) Used when deleting the Storage Account Local User.<br>- `read` - (Defaults to 5 minutes) Used when retrieving the Storage Account Local User.<br>- `update` - (Defaults to 30 minutes) Used when updating the Storage Account Local User. | <pre>map(object({<br>    home_directory       = optional(string)<br>    name                 = string<br>    ssh_key_enabled      = optional(bool)<br>    ssh_password_enabled = optional(bool)<br>    permission_scope = optional(list(object({<br>      resource_name = string<br>      service       = string<br>      permissions = object({<br>        create = optional(bool)<br>        delete = optional(bool)<br>        list   = optional(bool)<br>        read   = optional(bool)<br>        write  = optional(bool)<br>      })<br>    })))<br>    ssh_authorized_key = optional(list(object({<br>      description = optional(string)<br>      key         = string<br>    })))<br>    timeouts = optional(object({<br>      create = optional(string)<br>      delete = optional(string)<br>      read   = optional(string)<br>      update = optional(string)<br>    }))<br>  }))</pre> | `{}` | no |
| <a name="input_storage_account_location"></a> [storage\_account\_location](#input\_storage\_account\_location) | (Required) Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created. | `string` | n/a | yes |
| <a name="input_storage_account_min_tls_version"></a> [storage\_account\_min\_tls\_version](#input\_storage\_account\_min\_tls\_version) | (Optional) The minimum supported TLS version for the storage account. Possible values are `TLS1_0`, `TLS1_1`, and `TLS1_2`. Defaults to `TLS1_2` for new storage accounts. | `string` | `null` | no |
| <a name="input_storage_account_name"></a> [storage\_account\_name](#input\_storage\_account\_name) | (Required) Specifies the name of the storage account. Only lowercase Alphanumeric characters allowed. Changing this forces a new resource to be created. This must be unique across the entire Azure service, not just within the resource group. | `string` | n/a | yes |
| <a name="input_storage_account_network_rules"></a> [storage\_account\_network\_rules](#input\_storage\_account\_network\_rules) | - `bypass` - (Optional) Specifies whether traffic is bypassed for Logging/Metrics/AzureServices. Valid options are any combination of `Logging`, `Metrics`, `AzureServices`, or `None`.<br>- `default_action` - (Required) Specifies the default action of allow or deny when no other rules match. Valid options are `Deny` or `Allow`.<br>- `ip_rules` - (Optional) List of public IP or IP ranges in CIDR Format. Only IPv4 addresses are allowed. Private IP address ranges (as defined in [RFC 1918](https://tools.ietf.org/html/rfc1918#section-3)) are not allowed.<br>- `storage_account_id` - (Required) Specifies the ID of the storage account. Changing this forces a new resource to be created.<br>- `virtual_network_subnet_ids` - (Optional) A list of virtual network subnet ids to secure the storage account.<br><br>---<br>`private_link_access` block supports the following:<br>- `endpoint_resource_id` - (Required) The resource id of the resource access rule to be granted access.<br>- `endpoint_tenant_id` - (Optional) The tenant id of the resource of the resource access rule to be granted access. Defaults to the current tenant id.<br><br>---<br>`timeouts` block supports the following:<br>- `create` - (Defaults to 60 minutes) Used when creating the  Network Rules for this Storage Account.<br>- `delete` - (Defaults to 60 minutes) Used when deleting the Network Rules for this Storage Account.<br>- `read` - (Defaults to 5 minutes) Used when retrieving the Network Rules for this Storage Account.<br>- `update` - (Defaults to 60 minutes) Used when updating the Network Rules for this Storage Account. | <pre>object({<br>    bypass                     = optional(set(string), ["Logging", "Metrics", "AzureServices"])<br>    default_action             = optional(string, "Deny")<br>    ip_rules                   = optional(set(string), [])<br>    virtual_network_subnet_ids = optional(set(string))<br>    private_link_access = optional(list(object({<br>      endpoint_resource_id = string<br>      endpoint_tenant_id   = optional(string)<br>    })))<br>    timeouts = optional(object({<br>      create = optional(string)<br>      delete = optional(string)<br>      read   = optional(string)<br>      update = optional(string)<br>    }))<br>  })</pre> | `null` | no |
| <a name="input_storage_account_nfsv3_enabled"></a> [storage\_account\_nfsv3\_enabled](#input\_storage\_account\_nfsv3\_enabled) | (Optional) Is NFSv3 protocol enabled? Changing this forces a new resource to be created. Defaults to `false`. | `bool` | `null` | no |
| <a name="input_storage_account_public_network_access_enabled"></a> [storage\_account\_public\_network\_access\_enabled](#input\_storage\_account\_public\_network\_access\_enabled) | (Optional) Whether the public network access is enabled? Defaults to `true`. | `bool` | `null` | no |
| <a name="input_storage_account_queue_encryption_key_type"></a> [storage\_account\_queue\_encryption\_key\_type](#input\_storage\_account\_queue\_encryption\_key\_type) | (Optional) The encryption type of the queue service. Possible values are `Service` and `Account`. Changing this forces a new resource to be created. Default value is `Service`. | `string` | `null` | no |
| <a name="input_storage_account_queue_properties"></a> [storage\_account\_queue\_properties](#input\_storage\_account\_queue\_properties) | ---<br>`cors_rule` block supports the following:<br>- `allowed_headers` - (Required) A list of headers that are allowed to be a part of the cross-origin request.<br>- `allowed_methods` - (Required) A list of HTTP methods that are allowed to be executed by the origin. Valid options are `DELETE`, `GET`, `HEAD`, `MERGE`, `POST`, `OPTIONS`, `PUT` or `PATCH`.<br>- `allowed_origins` - (Required) A list of origin domains that will be allowed by CORS.<br>- `exposed_headers` - (Required) A list of response headers that are exposed to CORS clients.<br>- `max_age_in_seconds` - (Required) The number of seconds the client should cache a preflight response.<br><br>---<br>`hour_metrics` block supports the following:<br>- `enabled` - (Required) Indicates whether hour metrics are enabled for the Queue service.<br>- `include_apis` - (Optional) Indicates whether metrics should generate summary statistics for called API operations.<br>- `retention_policy_days` - (Optional) Specifies the number of days that logs will be retained.<br>- `version` - (Required) The version of storage analytics to configure.<br><br>---<br>`logging` block supports the following:<br>- `delete` - (Required) Indicates whether all delete requests should be logged.<br>- `read` - (Required) Indicates whether all read requests should be logged.<br>- `retention_policy_days` - (Optional) Specifies the number of days that logs will be retained.<br>- `version` - (Required) The version of storage analytics to configure.<br>- `write` - (Required) Indicates whether all write requests should be logged.<br><br>---<br>`minute_metrics` block supports the following:<br>- `enabled` - (Required) Indicates whether minute metrics are enabled for the Queue service.<br>- `include_apis` - (Optional) Indicates whether metrics should generate summary statistics for called API operations.<br>- `retention_policy_days` - (Optional) Specifies the number of days that logs will be retained.<br>- `version` - (Required) The version of storage analytics to configure. | <pre>object({<br>    cors_rule = optional(list(object({<br>      allowed_headers    = list(string)<br>      allowed_methods    = list(string)<br>      allowed_origins    = list(string)<br>      exposed_headers    = list(string)<br>      max_age_in_seconds = number<br>    })))<br>    hour_metrics = optional(object({<br>      enabled               = bool<br>      include_apis          = optional(bool)<br>      retention_policy_days = optional(number)<br>      version               = string<br>    }))<br>    logging = optional(object({<br>      delete                = bool<br>      read                  = bool<br>      retention_policy_days = optional(number)<br>      version               = string<br>      write                 = bool<br>    }))<br>    minute_metrics = optional(object({<br>      enabled               = bool<br>      include_apis          = optional(bool)<br>      retention_policy_days = optional(number)<br>      version               = string<br>    }))<br>  })</pre> | `null` | no |
| <a name="input_storage_account_resource_group_name"></a> [storage\_account\_resource\_group\_name](#input\_storage\_account\_resource\_group\_name) | (Required) The name of the resource group in which to create the storage account. Changing this forces a new resource to be created. | `string` | n/a | yes |
| <a name="input_storage_account_routing"></a> [storage\_account\_routing](#input\_storage\_account\_routing) | - `choice` - (Optional) Specifies the kind of network routing opted by the user. Possible values are `InternetRouting` and `MicrosoftRouting`. Defaults to `MicrosoftRouting`.<br>- `publish_internet_endpoints` - (Optional) Should internet routing storage endpoints be published? Defaults to `false`.<br>- `publish_microsoft_endpoints` - (Optional) Should Microsoft routing storage endpoints be published? Defaults to `false`. | <pre>object({<br>    choice                      = optional(string)<br>    publish_internet_endpoints  = optional(bool)<br>    publish_microsoft_endpoints = optional(bool)<br>  })</pre> | `null` | no |
| <a name="input_storage_account_sas_policy"></a> [storage\_account\_sas\_policy](#input\_storage\_account\_sas\_policy) | - `expiration_action` - (Optional) The SAS expiration action. The only possible value is `Log` at this moment. Defaults to `Log`.<br>- `expiration_period` - (Required) The SAS expiration period in format of `DD.HH:MM:SS`. | <pre>object({<br>    expiration_action = optional(string)<br>    expiration_period = string<br>  })</pre> | `null` | no |
| <a name="input_storage_account_sftp_enabled"></a> [storage\_account\_sftp\_enabled](#input\_storage\_account\_sftp\_enabled) | (Optional) Boolean, enable SFTP for the storage account | `bool` | `null` | no |
| <a name="input_storage_account_share_properties"></a> [storage\_account\_share\_properties](#input\_storage\_account\_share\_properties) | ---<br>`cors_rule` block supports the following:<br>- `allowed_headers` - (Required) A list of headers that are allowed to be a part of the cross-origin request.<br>- `allowed_methods` - (Required) A list of HTTP methods that are allowed to be executed by the origin. Valid options are `DELETE`, `GET`, `HEAD`, `MERGE`, `POST`, `OPTIONS`, `PUT` or `PATCH`.<br>- `allowed_origins` - (Required) A list of origin domains that will be allowed by CORS.<br>- `exposed_headers` - (Required) A list of response headers that are exposed to CORS clients.<br>- `max_age_in_seconds` - (Required) The number of seconds the client should cache a preflight response.<br><br>---<br>`retention_policy` block supports the following:<br>- `days` - (Optional) Specifies the number of days that the `azurerm_storage_share` should be retained, between `1` and `365` days. Defaults to `7`.<br><br>---<br>`smb` block supports the following:<br>- `authentication_types` - (Optional) A set of SMB authentication methods. Possible values are `NTLMv2`, and `Kerberos`.<br>- `channel_encryption_type` - (Optional) A set of SMB channel encryption. Possible values are `AES-128-CCM`, `AES-128-GCM`, and `AES-256-GCM`.<br>- `kerberos_ticket_encryption_type` - (Optional) A set of Kerberos ticket encryption. Possible values are `RC4-HMAC`, and `AES-256`.<br>- `multichannel_enabled` - (Optional) Indicates whether multichannel is enabled. Defaults to `false`. This is only supported on Premium storage accounts.<br>- `versions` - (Optional) A set of SMB protocol versions. Possible values are `SMB2.1`, `SMB3.0`, and `SMB3.1.1`. | <pre>object({<br>    cors_rule = optional(list(object({<br>      allowed_headers    = list(string)<br>      allowed_methods    = list(string)<br>      allowed_origins    = list(string)<br>      exposed_headers    = list(string)<br>      max_age_in_seconds = number<br>    })))<br>    retention_policy = optional(object({<br>      days = optional(number)<br>    }))<br>    smb = optional(object({<br>      authentication_types            = optional(set(string))<br>      channel_encryption_type         = optional(set(string))<br>      kerberos_ticket_encryption_type = optional(set(string))<br>      multichannel_enabled            = optional(bool)<br>      versions                        = optional(set(string))<br>    }))<br>  })</pre> | `null` | no |
| <a name="input_storage_account_shared_access_key_enabled"></a> [storage\_account\_shared\_access\_key\_enabled](#input\_storage\_account\_shared\_access\_key\_enabled) | (Optional) Indicates whether the storage account permits requests to be authorized with the account access key via Shared Key. If false, then all requests, including shared access signatures, must be authorized with Azure Active Directory (Azure AD). The default value is `true`. | `bool` | `null` | no |
| <a name="input_storage_account_static_website"></a> [storage\_account\_static\_website](#input\_storage\_account\_static\_website) | - `error_404_document` - (Optional) The absolute path to a custom webpage that should be used when a request is made which does not correspond to an existing file.<br>- `index_document` - (Optional) The webpage that Azure Storage serves for requests to the root of a website or any subfolder. For example, index.html. The value is case-sensitive. | <pre>object({<br>    error_404_document = optional(string)<br>    index_document     = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_storage_account_table_encryption_key_type"></a> [storage\_account\_table\_encryption\_key\_type](#input\_storage\_account\_table\_encryption\_key\_type) | (Optional) The encryption type of the table service. Possible values are `Service` and `Account`. Changing this forces a new resource to be created. Default value is `Service`. | `string` | `null` | no |
| <a name="input_storage_account_tags"></a> [storage\_account\_tags](#input\_storage\_account\_tags) | (Optional) A mapping of tags to assign to the resource. | `map(string)` | `null` | no |
| <a name="input_storage_account_timeouts"></a> [storage\_account\_timeouts](#input\_storage\_account\_timeouts) | - `create` - (Defaults to 60 minutes) Used when creating the Storage Account.<br>- `delete` - (Defaults to 60 minutes) Used when deleting the Storage Account.<br>- `read` - (Defaults to 5 minutes) Used when retrieving the Storage Account.<br>- `update` - (Defaults to 60 minutes) Used when updating the Storage Account. | <pre>object({<br>    create = optional(string)<br>    delete = optional(string)<br>    read   = optional(string)<br>    update = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_storage_container"></a> [storage\_container](#input\_storage\_container) | - `container_access_type` - (Optional) The Access Level configured for this Container. Possible values are `blob`, `container` or `private`. Defaults to `private`.<br>- `metadata` - (Optional) A mapping of MetaData for this Container. All metadata keys should be lowercase.<br>- `name` - (Required) The name of the Container which should be created within the Storage Account. Changing this forces a new resource to be created.<br><br>---<br>`timeouts` block supports the following:<br>- `create` - (Defaults to 30 minutes) Used when creating the Storage Container.<br>- `delete` - (Defaults to 30 minutes) Used when deleting the Storage Container.<br>- `read` - (Defaults to 5 minutes) Used when retrieving the Storage Container.<br>- `update` - (Defaults to 30 minutes) Used when updating the Storage Container. | <pre>map(object({<br>    container_access_type = optional(string)<br>    metadata              = optional(map(string))<br>    name                  = string<br>    timeouts = optional(object({<br>      create = optional(string)<br>      delete = optional(string)<br>      read   = optional(string)<br>      update = optional(string)<br>    }))<br>  }))</pre> | `{}` | no |
| <a name="input_storage_queue"></a> [storage\_queue](#input\_storage\_queue) | - `metadata` - (Optional) A mapping of MetaData which should be assigned to this Storage Queue.<br>- `name` - (Required) The name of the Queue which should be created within the Storage Account. Must be unique within the storage account the queue is located. Changing this forces a new resource to be created.<br><br>---<br>`timeouts` block supports the following:<br>- `create` - (Defaults to 30 minutes) Used when creating the Storage Queue.<br>- `delete` - (Defaults to 30 minutes) Used when deleting the Storage Queue.<br>- `read` - (Defaults to 5 minutes) Used when retrieving the Storage Queue.<br>- `update` - (Defaults to 30 minutes) Used when updating the Storage Queue. | <pre>map(object({<br>    metadata = optional(map(string))<br>    name     = string<br>    timeouts = optional(object({<br>      create = optional(string)<br>      delete = optional(string)<br>      read   = optional(string)<br>      update = optional(string)<br>    }))<br>  }))</pre> | `{}` | no |
| <a name="input_storage_share"></a> [storage\_share](#input\_storage\_share) | - `access_tier` - (Optional) The access tier of the File Share. Possible values are `Hot`, `Cool` and `TransactionOptimized`, `Premium`.<br>- `enabled_protocol` - (Optional) The protocol used for the share. Possible values are `SMB` and `NFS`. The `SMB` indicates the share can be accessed by SMBv3.0, SMBv2.1 and REST. The `NFS` indicates the share can be accessed by NFSv4.1. Defaults to `SMB`. Changing this forces a new resource to be created.<br>- `metadata` - (Optional) A mapping of MetaData for this File Share.<br>- `name` - (Required) The name of the share. Must be unique within the storage account where the share is located. Changing this forces a new resource to be created.<br>- `quota` - (Required) The maximum size of the share, in gigabytes. For Standard storage accounts, this must be `1`GB (or higher) and at most `5120` GB (`5` TB). For Premium FileStorage storage accounts, this must be greater than 100 GB and at most `102400` GB (`100` TB).<br><br>---<br>`acl` block supports the following:<br>- `id` - (Required) The ID which should be used for this Shared Identifier.<br><br>---<br>`access_policy` block supports the following:<br>- `expiry` - (Optional) The time at which this Access Policy should be valid until, in [ISO8601](https://en.wikipedia.org/wiki/ISO_8601) format.<br>- `permissions` - (Required) The permissions which should be associated with this Shared Identifier. Possible value is combination of `r` (read), `w` (write), `d` (delete), and `l` (list).<br>- `start` - (Optional) The time at which this Access Policy should be valid from, in [ISO8601](https://en.wikipedia.org/wiki/ISO_8601) format.<br><br>---<br>`timeouts` block supports the following:<br>- `create` - (Defaults to 30 minutes) Used when creating the Storage Share.<br>- `delete` - (Defaults to 30 minutes) Used when deleting the Storage Share.<br>- `read` - (Defaults to 5 minutes) Used when retrieving the Storage Share.<br>- `update` - (Defaults to 30 minutes) Used when updating the Storage Share. | <pre>map(object({<br>    access_tier      = optional(string)<br>    enabled_protocol = optional(string)<br>    metadata         = optional(map(string))<br>    name             = string<br>    quota            = number<br>    acl = optional(set(object({<br>      id = string<br>      access_policy = optional(list(object({<br>        expiry      = optional(string)<br>        permissions = string<br>        start       = optional(string)<br>      })))<br>    })))<br>    timeouts = optional(object({<br>      create = optional(string)<br>      delete = optional(string)<br>      read   = optional(string)<br>      update = optional(string)<br>    }))<br>  }))</pre> | `{}` | no |
| <a name="input_storage_table"></a> [storage\_table](#input\_storage\_table) | - `name` - (Required) The name of the storage table. Only Alphanumeric characters allowed, starting with a letter. Must be unique within the storage account the table is located. Changing this forces a new resource to be created.<br><br>---<br>`acl` block supports the following:<br>- `id` - (Required) The ID which should be used for this Shared Identifier.<br><br>---<br>`access_policy` block supports the following:<br>- `expiry` - (Required) The ISO8061 UTC time at which this Access Policy should be valid until.<br>- `permissions` - (Required) The permissions which should associated with this Shared Identifier.<br>- `start` - (Required) The ISO8061 UTC time at which this Access Policy should be valid from.<br><br>---<br>`timeouts` block supports the following:<br>- `create` - (Defaults to 30 minutes) Used when creating the Storage Table.<br>- `delete` - (Defaults to 30 minutes) Used when deleting the Storage Table.<br>- `read` - (Defaults to 5 minutes) Used when retrieving the Storage Table.<br>- `update` - (Defaults to 30 minutes) Used when updating the Storage Table. | <pre>map(object({<br>    name = string<br>    acl = optional(set(object({<br>      id = string<br>      access_policy = optional(list(object({<br>        expiry      = string<br>        permissions = string<br>        start       = string<br>      })))<br>    })))<br>    timeouts = optional(object({<br>      create = optional(string)<br>      delete = optional(string)<br>      read   = optional(string)<br>      update = optional(string)<br>    }))<br>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_fqdn"></a> [fqdn](#output\_fqdn) | Fqdns for storage services. |
| <a name="output_private_endpoint_id"></a> [private\_endpoint\_id](#output\_private\_endpoint\_id) | Id of created private endpoint |
| <a name="output_private_endpoint_private_ip"></a> [private\_endpoint\_private\_ip](#output\_private\_endpoint\_private\_ip) | Map of private IP of created private endpoints |
| <a name="output_storage_account_id"></a> [storage\_account\_id](#output\_storage\_account\_id) | The ID of the Storage Account. |
| <a name="output_storage_account_name"></a> [storage\_account\_name](#output\_storage\_account\_name) | The name of the storage account |
| <a name="output_storage_account_primary_access_key"></a> [storage\_account\_primary\_access\_key](#output\_storage\_account\_primary\_access\_key) | The primary access key for the storage account. |
| <a name="output_storage_account_primary_blob_connection_string"></a> [storage\_account\_primary\_blob\_connection\_string](#output\_storage\_account\_primary\_blob\_connection\_string) | The connection string associated with the primary blob location. |
| <a name="output_storage_account_primary_blob_endpoint"></a> [storage\_account\_primary\_blob\_endpoint](#output\_storage\_account\_primary\_blob\_endpoint) | The endpoint URL for blob storage in the primary location. |
| <a name="output_storage_account_primary_blob_host"></a> [storage\_account\_primary\_blob\_host](#output\_storage\_account\_primary\_blob\_host) | The hostname with port if applicable for blob storage in the primary location. |
| <a name="output_storage_account_primary_connection_string"></a> [storage\_account\_primary\_connection\_string](#output\_storage\_account\_primary\_connection\_string) | The connection string associated with the primary location. |
| <a name="output_storage_account_primary_location"></a> [storage\_account\_primary\_location](#output\_storage\_account\_primary\_location) | The primary location of the storage account. |
| <a name="output_storage_account_primary_queue_endpoint"></a> [storage\_account\_primary\_queue\_endpoint](#output\_storage\_account\_primary\_queue\_endpoint) | The endpoint URL for queue storage in the primary location. |
| <a name="output_storage_account_primary_queue_host"></a> [storage\_account\_primary\_queue\_host](#output\_storage\_account\_primary\_queue\_host) | The hostname with port if applicable for queue storage in the primary location. |
| <a name="output_storage_account_primary_table_endpoint"></a> [storage\_account\_primary\_table\_endpoint](#output\_storage\_account\_primary\_table\_endpoint) | The endpoint URL for table storage in the primary location. |
| <a name="output_storage_account_primary_table_host"></a> [storage\_account\_primary\_table\_host](#output\_storage\_account\_primary\_table\_host) | The hostname with port if applicable for table storage in the primary location. |
| <a name="output_storage_account_secondary_access_key"></a> [storage\_account\_secondary\_access\_key](#output\_storage\_account\_secondary\_access\_key) | The secondary access key for the storage account. |
| <a name="output_storage_account_secondary_blob_connection_string"></a> [storage\_account\_secondary\_blob\_connection\_string](#output\_storage\_account\_secondary\_blob\_connection\_string) | The connection string associated with the secondary blob location. |
| <a name="output_storage_account_secondary_blob_endpoint"></a> [storage\_account\_secondary\_blob\_endpoint](#output\_storage\_account\_secondary\_blob\_endpoint) | The endpoint URL for blob storage in the secondary location. |
| <a name="output_storage_account_secondary_blob_host"></a> [storage\_account\_secondary\_blob\_host](#output\_storage\_account\_secondary\_blob\_host) | The hostname with port if applicable for blob storage in the secondary location. |
| <a name="output_storage_account_secondary_connection_string"></a> [storage\_account\_secondary\_connection\_string](#output\_storage\_account\_secondary\_connection\_string) | The connection string associated with the secondary location. |
| <a name="output_storage_account_secondary_location"></a> [storage\_account\_secondary\_location](#output\_storage\_account\_secondary\_location) | The secondary location of the storage account. |
| <a name="output_storage_account_secondary_queue_endpoint"></a> [storage\_account\_secondary\_queue\_endpoint](#output\_storage\_account\_secondary\_queue\_endpoint) | The endpoint URL for queue storage in the secondary location. |
| <a name="output_storage_account_secondary_queue_host"></a> [storage\_account\_secondary\_queue\_host](#output\_storage\_account\_secondary\_queue\_host) | The hostname with port if applicable for queue storage in the secondary location. |
| <a name="output_storage_account_secondary_table_endpoint"></a> [storage\_account\_secondary\_table\_endpoint](#output\_storage\_account\_secondary\_table\_endpoint) | The endpoint URL for table storage in the secondary location. |
| <a name="output_storage_account_secondary_table_host"></a> [storage\_account\_secondary\_table\_host](#output\_storage\_account\_secondary\_table\_host) | The hostname with port if applicable for table storage in the secondary location. |
| <a name="output_storage_container"></a> [storage\_container](#output\_storage\_container) | Map of storage containers that created. |
| <a name="output_storage_queue"></a> [storage\_queue](#output\_storage\_queue) | Map of storage queues that created. |
| <a name="output_storage_table"></a> [storage\_table](#output\_storage\_table) | Map of storage tables that created. |
<!-- END_TF_DOCS -->

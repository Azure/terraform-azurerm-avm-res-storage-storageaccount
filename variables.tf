variable "location" {
  type        = string
  description = <<DESCRIPTION
Azure region where the resource should be deployed.
If null, the location will be inferred from the resource group location.
DESCRIPTION
  nullable    = false
}

variable "name" {
  type        = string
  description = "The name of the resource."

  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.name))
    error_message = "The name must be between 3 and 24 characters, valid characters are lowercase letters and numbers."
  }
}

variable "parent_id" {
  type        = string
  description = "The Azure resource ID of the parent resource group, in the form `/subscriptions/{subscription_id}/resourceGroups/{resource_group_name}`."
  nullable    = false

  validation {
    condition     = can(regex("^/subscriptions/[^/]+/resourceGroups/[^/]+$", var.parent_id))
    error_message = "`parent_id` must be a valid resource group resource ID, in the form `/subscriptions/{subscription_id}/resourceGroups/{resource_group_name}`."
  }
}

variable "customer_managed_key" {
  type = object({
    key_vault_resource_id = string
    key_name              = string
    key_version           = optional(string, null)
    user_assigned_identity = optional(object({
      resource_id = string
    }), null)
  })
  default     = null
  description = <<DESCRIPTION
Defines a customer managed key to use for encryption. Defaults to `null` (Microsoft-managed keys).

- `key_vault_resource_id` - (Required) The full Azure Resource ID of the key vault where the customer managed key will be referenced from.
- `key_name` - (Required) The key name for the customer managed key in the key vault.
- `key_version` - (Optional) The version of the key to use. If `null`, the latest version is tracked automatically.
- `user_assigned_identity` - (Optional) A user assigned identity used to access the key vault. Defaults to `null`, in which case the storage account's system-assigned identity is used.
  - `resource_id` - (Required) The full Azure Resource ID of the user assigned identity.

Example Inputs:
```terraform
customer_managed_key = {
  key_vault_resource_id = "/subscriptions/0000000-0000-0000-0000-000000000000/resourceGroups/test-resource-group/providers/Microsoft.KeyVault/vaults/example-key-vault"
  key_name              = "sample-customer-key"
}
```
DESCRIPTION
}

variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see <https://aka.ms/avm/telemetryinfo>.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
  nullable    = false
}

variable "lock" {
  type = object({
    name = optional(string, null)
    kind = string
  })
  default     = null
  description = <<DESCRIPTION
Controls the management lock applied to the storage account. Defaults to `null` (no lock).

- `kind` - (Required) The kind of lock to apply. Possible values are `CanNotDelete` and `ReadOnly`.
- `name` - (Optional) The name of the lock. If not specified, a name will be generated.
DESCRIPTION

  validation {
    condition     = var.lock != null ? contains(["CanNotDelete", "ReadOnly"], var.lock.kind) : true
    error_message = "Lock kind must be either `\"CanNotDelete\"` or `\"ReadOnly\"`."
  }
}

variable "managed_identities" {
  type = object({
    system_assigned            = optional(bool, false)
    user_assigned_resource_ids = optional(set(string), [])
  })
  default     = {}
  description = <<DESCRIPTION
  Controls the Managed Identity configuration on this resource. The following properties can be specified:

  - `system_assigned` - (Optional) Specifies if the System Assigned Managed Identity should be enabled.
  - `user_assigned_resource_ids` - (Optional) Specifies a list of User Assigned Managed Identity resource IDs to be assigned to this resource.
  DESCRIPTION
  nullable    = false
}

variable "private_endpoints" {
  type = map(object({
    name = optional(string, null)
    role_assignments = optional(map(object({
      role_definition_id_or_name             = string
      principal_id                           = string
      description                            = optional(string, null)
      skip_service_principal_aad_check       = optional(bool, false)
      condition                              = optional(string, null)
      condition_version                      = optional(string, null)
      delegated_managed_identity_resource_id = optional(string, null)
      principal_type                         = optional(string, null)
    })), {})
    lock = optional(object({
      kind = string
      name = optional(string, null)
    }), null)
    tags                                    = optional(map(string), null)
    subnet_resource_id                      = string
    subresource_name                        = string
    private_dns_zone_group_name             = optional(string, "default")
    private_dns_zone_resource_ids           = optional(set(string), [])
    application_security_group_associations = optional(map(string), {})
    private_service_connection_name         = optional(string, null)
    network_interface_name                  = optional(string, null)
    location                                = optional(string, null)
    resource_group_name                     = optional(string, null)
    ip_configurations = optional(map(object({
      name               = string
      private_ip_address = string
    })), {})
  }))
  default     = {}
  description = <<DESCRIPTION
A map of private endpoints to create on the resource. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time. Defaults to `{}` (no private endpoints).

- `subnet_resource_id` - (Required) The resource ID of the subnet to deploy the private endpoint in.
- `subresource_name` - (Required) The service name of the private endpoint. Possible values are `blob`, `dfs`, `file`, `queue`, `table`, and `web`.
- `name` - (Optional) The name of the private endpoint. One will be generated if not set. The name must be set if multiple private endpoints are created to avoid conflicting resources.
- `role_assignments` - (Optional) A map of role assignments to create on the private endpoint. Defaults to `{}`. The map key is deliberately arbitrary to avoid issues where map keys may be unknown at plan time. Each value supports:
  - `role_definition_id_or_name` - (Required) The ID or name of the role definition to assign to the principal.
  - `principal_id` - (Required) The ID of the principal to assign the role to.
  - `description` - (Optional) The description of the role assignment. Defaults to `null`.
  - `skip_service_principal_aad_check` - (Optional) Retained for backwards compatibility with the legacy `azurerm` schema. Not honoured under AzAPI: the field is accepted but has no effect on the underlying role assignment. Defaults to `false`.
  - `condition` - (Optional) The condition which will be used to scope the role assignment. Defaults to `null`.
  - `condition_version` - (Optional) The version of the condition syntax. Valid value is `2.0`. Defaults to `null`.
  - `delegated_managed_identity_resource_id` - (Optional) The resource ID of the delegated managed identity. Defaults to `null`.
  - `principal_type` - (Optional) The type of principal. One of `User`, `Group`, `ServicePrincipal`, `ForeignGroup`, `Device`. Defaults to `null`.
- `lock` - (Optional) The management lock to apply to the private endpoint. Defaults to `null` (no lock). Supports:
  - `kind` - (Required) The kind of lock. Possible values are `CanNotDelete` and `ReadOnly`.
  - `name` - (Optional) The name of the lock. Defaults to `null` (auto-generated).
- `tags` - (Optional) A mapping of tags to assign to the private endpoint. Defaults to `null`.
- `private_dns_zone_group_name` - (Optional) The name of the private DNS zone group. Defaults to `default`.
- `private_dns_zone_resource_ids` - (Optional) A set of resource IDs of private DNS zones to associate with the private endpoint. Defaults to `[]`. If empty, no zone groups will be created and the private endpoint will not be associated with any private DNS zones; DNS records must be managed external to this module.
- `application_security_group_associations` - (Optional) A map of resource IDs of application security groups to associate with the private endpoint. Defaults to `{}`. The map key is deliberately arbitrary to avoid issues where map keys may be unknown at plan time; the value is the application security group resource ID.
- `private_service_connection_name` - (Optional) The name of the private service connection. One will be generated if not set. Defaults to `null`.
- `network_interface_name` - (Optional) The name of the network interface. One will be generated if not set. Defaults to `null`.
- `location` - (Optional) The Azure location where the resources will be deployed. Defaults to the location of the storage account.
- `resource_group_name` - (Optional) The resource group where the resources will be deployed. Defaults to the resource group of the storage account.
- `ip_configurations` - (Optional) A map of IP configurations to create on the private endpoint. Defaults to `{}` (the platform allocates IPs). The map key is deliberately arbitrary to avoid issues where map keys may be unknown at plan time. Each value supports:
  - `name` - (Required) The name of the IP configuration.
  - `private_ip_address` - (Required) The private IP address of the IP configuration.
DESCRIPTION
  nullable    = false
}

variable "private_endpoints_manage_dns_zone_group" {
  type        = bool
  default     = true
  description = "Whether to manage private DNS zone groups with this module. Defaults to `true`. If set to `false`, you must manage private DNS zone groups externally, e.g. using Azure Policy."
  nullable    = false
}

variable "resource_types" {
  type = object({
    storage_account            = optional(string, "Microsoft.Storage/storageAccounts@2025-06-01")
    customer_managed_key_vault = optional(string, "Microsoft.KeyVault/vaults@2024-11-01")
    lock                       = optional(string, "Microsoft.Authorization/locks@2020-05-01")
    blob_container             = optional(string, "Microsoft.Storage/storageAccounts/blobServices/containers@2025-06-01")
    blob_service               = optional(string, "Microsoft.Storage/storageAccounts/blobServices@2025-06-01")
    queue                      = optional(string, "Microsoft.Storage/storageAccounts/queueServices/queues@2025-06-01")
    table                      = optional(string, "Microsoft.Storage/storageAccounts/tableServices/tables@2025-06-01")
    share                      = optional(string, "Microsoft.Storage/storageAccounts/fileServices/shares@2025-06-01")
    local_user                 = optional(string, "Microsoft.Storage/storageAccounts/localUsers@2025-06-01")
    management_policy          = optional(string, "Microsoft.Storage/storageAccounts/managementPolicies@2025-06-01")
    queue_service              = optional(string, "Microsoft.Storage/storageAccounts/queueServices@2025-06-01")
    private_endpoint           = optional(string, "Microsoft.Network/privateEndpoints@2025-05-01")
    private_dns_zone_group     = optional(string, "Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2025-05-01")
  })
  default     = {}
  description = <<DESCRIPTION
Override the AzAPI `<provider>/<resource>@<api-version>` strings used by this module. Each key defaults to a tested value; supply only the keys you want to override. Useful when targeting a sovereign cloud with older API versions, or when opting into a newer preview API.

- `storage_account`            - The storage account itself, used by both the create call and the customer-managed-key patch.
- `customer_managed_key_vault` - The Key Vault data source used to look up the vault URI when CMK is enabled.
- `lock`                       - Management lock applied to the storage account (and to private endpoints when configured).
- `blob_container`             - Blob containers (also used by Data Lake Gen2 filesystems, which are blob containers in ARM).
- `blob_service`               - The `blobServices/default` sub-resource, patched by the static-website and blob-service submodules.
- `queue`                      - Storage queues.
- `table`                      - Storage tables.
- `share`                      - File shares.
- `local_user`                 - SFTP local users.
- `management_policy`          - The lifecycle-management policy.
- `queue_service`              - The `queueServices/default` sub-resource, patched by the queue-service-properties submodule.
- `private_endpoint`           - Private endpoints created for the storage account.
- `private_dns_zone_group`     - The private DNS zone group resource attached to a private endpoint.
DESCRIPTION
  nullable    = false
}

variable "retry" {
  type = object({
    error_message_regex  = optional(list(string))
    interval_seconds     = optional(number)
    max_interval_seconds = optional(number)
  })
  default     = null
  description = <<DESCRIPTION
Retry configuration applied to every `azapi` resource managed by the module (root storage account and all submodules). Defaults to `null` (no custom retry).

- `error_message_regex`  - (Optional) A list of regex patterns matching error messages that trigger a retry.
- `interval_seconds`     - (Optional) Initial interval between retries in seconds.
- `max_interval_seconds` - (Optional) Maximum interval between retries in seconds.

See <https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource#retry> for full semantics.
DESCRIPTION
}

variable "role_assignment_definition_lookup_enabled" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
Whether the `Azure/avm-utl-interfaces/azure` module composed by the internal `role_assignments` submodule should resolve role definition names supplied via `role_definition_id_or_name` by querying the Azure Authorization API. Applies to every role assignment created by this module: the storage account scope (`var.role_assignments`), every container/queue/share/table scope and every private endpoint scope. Defaults to `true`.

Set to `false` if you only ever supply fully-qualified role definition resource IDs (`/subscriptions/.../providers/Microsoft.Authorization/roleDefinitions/<guid>`) in `role_definition_id_or_name`. Disabling the lookup avoids the API call, which is useful in air-gapped or permission-restricted environments where the calling identity lacks `Microsoft.Authorization/roleDefinitions/read` at the parent scope.
DESCRIPTION
  nullable    = false
}

variable "role_assignments" {
  type = map(object({
    role_definition_id_or_name             = string
    principal_id                           = string
    description                            = optional(string, null)
    skip_service_principal_aad_check       = optional(bool, false)
    condition                              = optional(string, null)
    condition_version                      = optional(string, null)
    delegated_managed_identity_resource_id = optional(string, null)
    principal_type                         = optional(string, null)
  }))
  default     = {}
  description = <<DESCRIPTION
A map of role assignments to create on the resource. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time. Defaults to `{}`.

- `role_definition_id_or_name` - (Required) The ID or name of the role definition to assign to the principal.
- `principal_id` - (Required) The ID of the principal to assign the role to.
- `description` - (Optional) The description of the role assignment. Defaults to `null`.
- `skip_service_principal_aad_check` - (Optional) Retained for backwards compatibility with the legacy `azurerm` schema. Not honoured under AzAPI: the field is accepted but has no effect on the underlying role assignment. Defaults to `false`.
- `condition` - (Optional) The condition which will be used to scope the role assignment. Defaults to `null`.
- `condition_version` - (Optional) The version of the condition syntax. Valid value is `2.0`. Defaults to `null`.
- `delegated_managed_identity_resource_id` - (Optional) The resource ID of the delegated managed identity. Defaults to `null`.
- `principal_type` - (Optional) The type of principal. One of `User`, `Group`, `ServicePrincipal`, `ForeignGroup`, `Device`. Defaults to `null`.
DESCRIPTION
  nullable    = false
}

variable "tags" {
  type        = map(string)
  default     = null
  description = "Custom tags to apply to the resource."
}

variable "timeouts" {
  type = object({
    create = optional(string)
    read   = optional(string)
    update = optional(string)
    delete = optional(string)
  })
  default     = null
  description = <<DESCRIPTION
Default per-operation timeouts applied to every `azapi` resource managed by the module. Defaults to `null` (provider defaults). Each value is a Go duration string (e.g. `30m`, `1h`).

- `create` - (Optional) Timeout for create operations. Defaults to `null`.
- `read` - (Optional) Timeout for read operations. Defaults to `null`.
- `update` - (Optional) Timeout for update operations. Defaults to `null`.
- `delete` - (Optional) Timeout for delete operations. Defaults to `null`.

The root storage account uses these values directly. Submodules (containers, queues, shares, tables, diagnostic settings, private endpoints, management policy, local users, role assignments, Data Lake Gen2 filesystems) use these as a default that can be overridden per-item via the item's own `timeouts` field.
DESCRIPTION
}

variable "location" {
  type        = string
  description = "(Required) The Azure region of the private endpoint."
  nullable    = false
}

variable "name" {
  type        = string
  description = "(Required) The name of the private endpoint."
  nullable    = false
}

variable "parent_id" {
  type        = string
  description = "(Required) The full resource ID of the resource group in which the private endpoint will be created."
  nullable    = false
}

variable "private_connection_resource_id" {
  type        = string
  description = "(Required) The full resource ID of the resource that the private endpoint connects to (the storage account)."
  nullable    = false
}

variable "subnet_resource_id" {
  type        = string
  description = "(Required) The subnet to deploy the private endpoint into."
  nullable    = false
}

variable "subresource_name" {
  type        = string
  description = "(Required) The target subresource name (e.g. `blob`, `dfs`, `file`, `queue`, `table`, `web`)."
  nullable    = false
}

variable "application_security_group_resource_ids" {
  type        = map(string)
  default     = {}
  description = "(Optional) Application security groups to associate with the private endpoint. Defaults to `{}`. Map key is arbitrary; value is the ASG resource ID."
  nullable    = false
}

variable "dns_zone_group_resource_type" {
  type        = string
  default     = "Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2025-05-01"
  description = "(Optional) Override the AzAPI `<provider>/<resource>@<api-version>` string used to manage the private DNS zone group attached to the private endpoint. Defaults to the value tested with this module version."
  nullable    = false
}

variable "ip_configurations" {
  type = map(object({
    name               = string
    private_ip_address = string
  }))
  default     = {}
  description = <<-EOT
(Optional) Static IP configurations for the private endpoint. Defaults to `{}` (the platform allocates IPs). The map key is arbitrary; each value supports:

- `name` - (Required) The name of the IP configuration.
- `private_ip_address` - (Required) The static private IP address to assign.
EOT
  nullable    = false
}

variable "lock" {
  type = object({
    name = optional(string, null)
    kind = string
  })
  default     = null
  description = <<-EOT
(Optional) Management lock to apply to the private endpoint. Defaults to `null` (no lock).

- `kind` - (Required) The kind of lock. Possible values are `CanNotDelete` and `ReadOnly`.
- `name` - (Optional) The name of the lock. Defaults to `null` (auto-generated).
EOT
}

variable "lock_resource_type" {
  type        = string
  default     = "Microsoft.Authorization/locks@2020-05-01"
  description = "(Optional) Override the AzAPI `<provider>/<resource>@<api-version>` string used to manage the management lock applied to the private endpoint. Defaults to the value tested with this module version."
  nullable    = false
}

variable "manage_dns_zone_group" {
  type        = bool
  default     = true
  description = "(Optional) Whether the private endpoint's DNS zone group should be managed by this module. Defaults to `true`."
  nullable    = false
}

variable "network_interface_name" {
  type        = string
  default     = null
  description = "(Optional) Custom name for the network interface created with the private endpoint. Defaults to `null` (auto-generated)."
}

variable "private_dns_zone_group_name" {
  type        = string
  default     = "default"
  description = "(Optional) The name of the private DNS zone group. Defaults to `default`."
}

variable "private_dns_zone_resource_ids" {
  type        = set(string)
  default     = []
  description = "(Optional) Private DNS zone resource IDs to associate with the private endpoint. Defaults to `[]` (no zones associated)."
  nullable    = false
}

variable "private_service_connection_name" {
  type        = string
  default     = null
  description = "(Optional) The name of the private service connection. Defaults to `null` (auto-generated as `pse-<endpoint name>`)."
}

variable "resource_type" {
  type        = string
  default     = "Microsoft.Network/privateEndpoints@2025-05-01"
  description = "(Optional) Override the AzAPI `<provider>/<resource>@<api-version>` string used to manage the private endpoint. Defaults to the value tested with this module version."
  nullable    = false
}

variable "retry" {
  type = object({
    error_message_regex  = optional(list(string))
    interval_seconds     = optional(number)
    max_interval_seconds = optional(number)
  })
  default     = null
  description = <<-EOT
(Optional) Retry configuration applied to AzAPI resources managed by this module. Defaults to `null` (no custom retry).

- `error_message_regex` - (Optional) A list of regex patterns matching error messages that trigger a retry. Defaults to `null`.
- `interval_seconds` - (Optional) Initial interval between retries in seconds. Defaults to `null` (provider default).
- `max_interval_seconds` - (Optional) Maximum interval between retries in seconds. Defaults to `null` (provider default).
EOT
}

variable "role_assignment_definition_lookup_enabled" {
  type        = bool
  default     = true
  description = "(Optional) Whether the `role_assignments` submodule should resolve role definition names supplied via `role_definition_id_or_name` by querying the Azure Authorization API. Defaults to `true`. See the `role_assignments` submodule for details."
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
  description = "(Optional) A map of role assignments to create at the private endpoint scope. Defaults to `{}`. See the `role_assignments` submodule for the attribute schema."
  nullable    = false
}

variable "tags" {
  type        = map(string)
  default     = null
  description = "(Optional) Tags to apply to the private endpoint. Defaults to `null` (no tags)."
}

variable "timeouts" {
  type = object({
    create = optional(string)
    read   = optional(string)
    update = optional(string)
    delete = optional(string)
  })
  default     = null
  description = <<-EOT
(Optional) Per-operation timeouts applied to AzAPI resources managed by this module. Defaults to `null` (provider defaults). Each value is a Go duration string (e.g. `30m`, `1h`).

- `create` - (Optional) Timeout for create operations. Defaults to `null`.
- `read` - (Optional) Timeout for read operations. Defaults to `null`.
- `update` - (Optional) Timeout for update operations. Defaults to `null`.
- `delete` - (Optional) Timeout for delete operations. Defaults to `null`.
EOT
}

variable "tracing_tags_header" {
  type        = string
  default     = null
  description = "(Optional) User-Agent string injected into AzAPI request headers. Defaults to `null` (no custom header)."
}

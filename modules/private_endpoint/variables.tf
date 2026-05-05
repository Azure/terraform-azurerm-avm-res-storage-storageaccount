variable "parent_id" {
  type        = string
  description = "(Required) The full resource ID of the resource group in which the private endpoint will be created."
  nullable    = false
}

variable "name" {
  type        = string
  description = "(Required) The name of the private endpoint."
  nullable    = false
}

variable "location" {
  type        = string
  description = "(Required) The Azure region of the private endpoint."
  nullable    = false
}

variable "tags" {
  type        = map(string)
  default     = null
  description = "(Optional) Tags to apply to the private endpoint."
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

variable "private_connection_resource_id" {
  type        = string
  description = "(Required) The full resource ID of the resource that the private endpoint connects to (the storage account)."
  nullable    = false
}

variable "private_service_connection_name" {
  type        = string
  default     = null
  description = "(Optional) The name of the private service connection. Defaults to `pse-<endpoint name>`."
}

variable "network_interface_name" {
  type        = string
  default     = null
  description = "(Optional) Custom name for the network interface created with the private endpoint."
}

variable "ip_configurations" {
  type = map(object({
    name               = string
    private_ip_address = string
  }))
  default     = {}
  description = "(Optional) Static IP configurations for the private endpoint."
  nullable    = false
}

variable "application_security_group_resource_ids" {
  type        = map(string)
  default     = {}
  description = "(Optional) Application security groups to associate with the private endpoint. Map key is arbitrary, value is the ASG resource ID."
  nullable    = false
}

variable "manage_dns_zone_group" {
  type        = bool
  default     = true
  description = "(Optional) Whether the private endpoint's DNS zone group should be managed by this module."
  nullable    = false
}

variable "private_dns_zone_group_name" {
  type        = string
  default     = "default"
  description = "(Optional) The name of the private DNS zone group."
}

variable "private_dns_zone_resource_ids" {
  type        = set(string)
  default     = []
  description = "(Optional) Private DNS zone resource IDs to associate with the private endpoint."
  nullable    = false
}

variable "lock" {
  type = object({
    name = optional(string, null)
    kind = string
  })
  default     = null
  description = "(Optional) Lock to apply to the private endpoint."
}

variable "role_assignments" {
  type = map(object({
    role_definition_id_or_name             = string
    principal_id                           = string
    principal_type                         = optional(string, null)
    description                            = optional(string, null)
    skip_service_principal_aad_check       = optional(bool, false)
    condition                              = optional(string, null)
    condition_version                      = optional(string, null)
    delegated_managed_identity_resource_id = optional(string, null)
  }))
  default     = {}
  description = "Map of role assignments to create at the private endpoint scope."
  nullable    = false
}

variable "retry" {
  type = object({
    error_message_regex  = optional(list(string))
    interval_seconds     = optional(number)
    max_interval_seconds = optional(number)
    multiplier           = optional(number)
    randomization_factor = optional(number)
  })
  default     = null
  description = "Retry configuration applied to AzAPI resources managed by this module."
}

variable "timeouts" {
  type = object({
    create = optional(string)
    read   = optional(string)
    update = optional(string)
    delete = optional(string)
  })
  default     = null
  description = "Timeouts applied to AzAPI resources managed by this module."
}

variable "tracing_tags_header" {
  type        = string
  default     = null
  description = "Optional User-Agent string injected into AzAPI request headers."
}

variable "enable_telemetry" {
  type        = bool
  default     = true
  description = "Controls whether telemetry headers are injected. Used in concert with `tracing_tags_header`."
  nullable    = false
}

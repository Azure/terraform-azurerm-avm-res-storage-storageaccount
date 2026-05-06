# NOTE: var.queue_properties (queue service-level CORS, logging, hour_metrics,
# minute_metrics) was removed in v1.0.0 (azapi rewrite). Configure those
# settings directly via `Microsoft.Storage/storageAccounts/queueServices` if
# needed; this module no longer exposes them.

variable "queue_encryption_key_type" {
  type        = string
  default     = null
  description = "(Optional) The encryption type of the queue service. Possible values are `Service` and `Account`. Defaults to `null` (Azure platform default of `Service`). Changing this forces a new resource to be created."
}

variable "queues" {
  type = map(object({
    metadata = optional(map(string))
    name     = string
    role_assignments = optional(map(object({
      role_definition_id_or_name             = string
      principal_id                           = string
      principal_type                         = optional(string, null)
      description                            = optional(string, null)
      skip_service_principal_aad_check       = optional(bool, false)
      condition                              = optional(string, null)
      condition_version                      = optional(string, null)
      delegated_managed_identity_resource_id = optional(string, null)
    })), {})
    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
      read   = optional(string)
      update = optional(string)
    }))
  }))
  default     = {}
  description = <<-EOT
A map of queues to create on the storage account. The map key is arbitrary; the value supports the following attributes. Defaults to `{}` (no queues).

- `name` - (Required) The name of the Queue which should be created within the Storage Account. Must be unique within the storage account. Changing this forces a new resource to be created.
- `metadata` - (Optional) A mapping of MetaData which should be assigned to this Storage Queue. Defaults to `null`.
- `role_assignments` - (Optional) A map of role assignments to create on the queue. Defaults to `{}`. See `var.role_assignments` for the attribute schema.
- `timeouts` - (Optional) Per-operation timeouts for the queue resource. Defaults to `null` (uses provider defaults inherited from `var.timeouts`). Supports:
  - `create` - (Optional) Timeout for create operations.
  - `delete` - (Optional) Timeout for delete operations.
  - `read` - (Optional) Timeout for read operations.
  - `update` - (Optional) Timeout for update operations.
EOT
  nullable    = false
}

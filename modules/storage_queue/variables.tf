# variable "name" {
#   description = "The name of the queue."
#   type        = string
# }

# variable "metadata" {
#   description = "Metadata info for the queue."
#   type        = map(string)
#   default     = {}
# }

# variable "storage_account_id" {
#   description = "The ID of the storage account."
#   type        = string
# }

# variable "timeouts" {
#   description = "Timeouts of the queue."
#   type = object({
#     create = optional(string)
#     delete = optional(string)
#     read   = optional(string)
#   })
#   default = null
}


variable "queues" {
  type = map(object({
    metadata = optional(map(string))
    name     = string
    storage_account_id = string
    role_assignments = optional(map(object({
      role_definition_id_or_name             = string
      principal_id                           = string
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
  default = {}
}

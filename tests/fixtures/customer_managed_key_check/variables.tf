variable "resource_id" {
  type        = string
  nullable    = false
  description = "The storage account resource ID to read independently after an update."

  validation {
    condition     = can(provider::azapi::parse_resource_id("Microsoft.Storage/storageAccounts", var.resource_id))
    error_message = "`resource_id` must be a valid storage account resource ID."
  }
}

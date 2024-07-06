variable "storage_account" {
  type = object({
    resource_id = string
  })
  description = <<DESCRIPTION
  (Required) The storage account to create the queue in.
  -resource_id: The resource ID of the storage account.
DESCRIPTION
  nullable    = false

}

variable "name" {
  type = string
}

variable "metadata" {
  type        = map(string)
  description = <<DESCRIPTION
  (Optional) A mapping of metadata to associate with the queue.
DESCRIPTION
  nullable    = true
  default     = {}
}


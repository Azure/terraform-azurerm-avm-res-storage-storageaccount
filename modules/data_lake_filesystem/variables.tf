variable "name" {
  type        = string
  description = "(Required) The name of the Data Lake Gen2 filesystem."
  nullable    = false
}

variable "storage_account_id" {
  type        = string
  description = "(Required) The full resource ID of the parent storage account."
  nullable    = false
}

variable "default_encryption_scope" {
  type        = string
  default     = null
  description = "(Optional) The default encryption scope to use for this filesystem. Defaults to `null` (the storage account default encryption scope is used)."
}

variable "metadata" {
  type        = map(string)
  default     = null
  description = "(Optional) A mapping of key-value pairs assigned to this filesystem. Defaults to `null` (no metadata)."
}

variable "resource_type" {
  type        = string
  default     = "Microsoft.Storage/storageAccounts/blobServices/containers@2025-06-01"
  description = "(Optional) Override the AzAPI `<provider>/<resource>@<api-version>` string used to manage the Data Lake Gen2 filesystem (a blob container in ARM). Defaults to the value tested with this module version."
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
(Optional) Retry configuration applied to the AzAPI resource. Defaults to `null` (no custom retry).

- `error_message_regex` - (Optional) A list of regex patterns matching error messages that trigger a retry. Defaults to `null`.
- `interval_seconds` - (Optional) Initial interval between retries in seconds. Defaults to `null` (provider default).
- `max_interval_seconds` - (Optional) Maximum interval between retries in seconds. Defaults to `null` (provider default).
EOT
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
(Optional) Per-operation timeouts applied to the AzAPI resource. Defaults to `null` (provider defaults). Each value is a Go duration string (e.g. `30m`, `1h`).

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

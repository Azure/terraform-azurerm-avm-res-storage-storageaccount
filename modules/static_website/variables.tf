variable "storage_account_id" {
  type        = string
  description = "(Required) The full resource ID of the parent storage account."
  nullable    = false
}

variable "error_404_document" {
  type        = string
  default     = null
  description = "(Optional) The absolute path to a custom webpage to use for 404 not-found errors. Defaults to `null` (Azure Storage returns the default error page)."
}

variable "index_document" {
  type        = string
  default     = null
  description = "(Optional) The webpage that Azure Storage serves for requests to the root of a website or any subfolder. Defaults to `null` (no index document configured)."
}

variable "resource_type" {
  type        = string
  default     = "Microsoft.Storage/storageAccounts/blobServices@2025-06-01"
  description = "(Optional) Override the AzAPI `<provider>/<resource>@<api-version>` string used to patch the blob service for static-website hosting. Defaults to the value tested with this module version."
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

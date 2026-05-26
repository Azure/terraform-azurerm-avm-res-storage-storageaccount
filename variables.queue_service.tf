variable "queue_properties" {
  type = object({
    cors_rules = optional(list(object({
      allowed_headers    = list(string)
      allowed_methods    = list(string)
      allowed_origins    = list(string)
      exposed_headers    = list(string)
      max_age_in_seconds = number
    })))
  })
  default     = null
  description = <<-EOT
Queue service-level settings for the storage account. Defaults to `null` (Azure platform defaults).

- `cors_rules` - (Optional) A list of CORS rules for the queue service. Defaults to `null`. Each entry supports:
  - `allowed_headers` - (Required) A list of headers allowed in cross-origin requests.
  - `allowed_methods` - (Required) A list of HTTP methods allowed.
  - `allowed_origins` - (Required) A list of origin domains allowed.
  - `exposed_headers` - (Required) A list of response headers exposed to CORS clients.
  - `max_age_in_seconds` - (Required) Seconds the browser should cache a preflight response.
EOT
}

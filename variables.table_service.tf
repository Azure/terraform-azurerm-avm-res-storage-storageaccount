variable "table_properties" {
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
Table service-level settings for the storage account. Defaults to `null` (Azure platform defaults).

- `cors_rules` - (Optional) A list of CORS rules for the table service. Defaults to `null`. Each entry supports:
  - `allowed_headers` - (Required) A list of headers allowed in cross-origin requests.
  - `allowed_methods` - (Required) A list of HTTP methods allowed.
  - `allowed_origins` - (Required) A list of origin domains allowed.
  - `exposed_headers` - (Required) A list of response headers exposed to CORS clients.
  - `max_age_in_seconds` - (Required) Seconds the browser should cache a preflight response.
EOT
}

variable "table_service_cors_propagation_wait" {
  type        = string
  default     = "2m"
  description = <<-EOT
(Optional) Duration to wait after the table service CORS PATCH before allowing dependents to refresh, expressed as a Go duration string (e.g. `2m`, `90s`). Defaults to `"2m"`.

The ARM `GET` on `tableServices/default` is eventually consistent: immediately after a successful PATCH the read can omit the `corsRules` that were just applied, which causes a follow-up `terraform plan` (and the post-apply idempotency check) to see false drift. The read-back stabilises after roughly two minutes. Set to `"0s"` to disable the wait entirely (not recommended when `table_properties.cors_rules` is set).
EOT
  nullable    = false
}

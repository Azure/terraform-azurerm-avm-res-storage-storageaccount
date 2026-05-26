variable "file_service_properties" {
  type = object({
    cors_rules = optional(list(object({
      allowed_headers    = list(string)
      allowed_methods    = list(string)
      allowed_origins    = list(string)
      exposed_headers    = list(string)
      max_age_in_seconds = number
    })))
    share_retention_policy = optional(object({
      days    = optional(number, 7)
      enabled = optional(bool, true)
    }))
    smb = optional(object({
      authentication_types            = optional(set(string))
      channel_encryption_types        = optional(set(string))
      kerberos_ticket_encryption_type = optional(set(string))
      multichannel_enabled            = optional(bool)
      versions                        = optional(set(string))
    }))
  })
  default     = null
  description = <<-EOT
File service-level settings for the storage account. Defaults to `null` (Azure platform defaults).

- `cors_rules` - (Optional) A list of CORS rules for the file service. Defaults to `null`. Each entry supports:
  - `allowed_headers` - (Required) A list of headers allowed in cross-origin requests.
  - `allowed_methods` - (Required) A list of HTTP methods allowed.
  - `allowed_origins` - (Required) A list of origin domains allowed.
  - `exposed_headers` - (Required) A list of response headers exposed to CORS clients.
  - `max_age_in_seconds` - (Required) Seconds the browser should cache a preflight response.
- `share_retention_policy` - (Optional) File share soft-delete retention policy. Defaults to `null`.
  - `days` - (Optional) Number of days to retain soft-deleted shares. Between 1 and 365. Defaults to `7`.
  - `enabled` - (Optional) Whether soft-delete is enabled. Defaults to `true`.
- `smb` - (Optional) SMB protocol settings. Defaults to `null`.
  - `authentication_types` - (Optional) Set of authentication types. Valid values: `NTLMv2`, `Kerberos`. Defaults to `null`.
  - `channel_encryption_types` - (Optional) Set of SMB channel encryption types. Valid values: `AES-128-CCM`, `AES-128-GCM`, `AES-256-GCM`. Defaults to `null`.
  - `kerberos_ticket_encryption_type` - (Optional) Set of Kerberos ticket encryption types. Valid values: `RC4-HMAC`, `AES-256`. Defaults to `null`.
  - `multichannel_enabled` - (Optional) Enable SMB multichannel (Premium file shares only). Defaults to `null`.
  - `versions` - (Optional) Set of SMB protocol versions. Valid values: `SMB2.1`, `SMB3.0`, `SMB3.1.1`. Defaults to `null`.
EOT
}

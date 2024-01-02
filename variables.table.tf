

variable "tables" {
  type = map(object({
    name = string
    acl = optional(set(object({
      id = string
      access_policy = optional(list(object({
        expiry      = string
        permissions = string
        start       = string
      })))
    })))
    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
      read   = optional(string)
      update = optional(string)
    }))
  }))
  default     = {}
  description = <<-EOT
 - `name` - (Required) The name of the storage table. Only Alphanumeric characters allowed, starting with a letter. Must be unique within the storage account the table is located. Changing this forces a new resource to be created.

 ---
 `acl` block supports the following:
 - `id` - (Required) The ID which should be used for this Shared Identifier.

 ---
 `access_policy` block supports the following:
 - `expiry` - (Required) The ISO8061 UTC time at which this Access Policy should be valid until.
 - `permissions` - (Required) The permissions which should associated with this Shared Identifier.
 - `start` - (Required) The ISO8061 UTC time at which this Access Policy should be valid from.

 ---
 `timeouts` block supports the following:
 - `create` - (Defaults to 30 minutes) Used when creating the Storage Table.
 - `delete` - (Defaults to 30 minutes) Used when deleting the Storage Table.
 - `read` - (Defaults to 5 minutes) Used when retrieving the Storage Table.
 - `update` - (Defaults to 30 minutes) Used when updating the Storage Table.
EOT
  nullable    = false
}

variable "table_encryption_key_type" {
  type        = string
  default     = null
  description = "(Optional) The encryption type of the table service. Possible values are `Service` and `Account`. Changing this forces a new resource to be created. Default value is `Service`."
}

variable "table_properties" {
  type = object({
    cors_rule = optional(list(object({
      allowed_headers    = list(string)
      allowed_methods    = list(string)
      allowed_origins    = list(string)
      exposed_headers    = list(string)
      max_age_in_seconds = number
    })))
    diagnostic_settings = optional(map(object({
      name                                     = optional(string, null)
      log_categories                           = optional(set(string), [])
      log_groups                               = optional(set(string), ["allLogs"])
      metric_categories                        = optional(set(string), ["AllMetrics"])
      log_analytics_destination_type           = optional(string, "Dedicated")
      workspace_resource_id                    = optional(string, null)
      resource_id                              = optional(string, null)
      event_hub_authorization_rule_resource_id = optional(string, null)
      event_hub_name                           = optional(string, null)
      marketplace_partner_resource_id          = optional(string, null)
    })), {})
  })
  default     = null
  description = <<-EOT

 ---
 `cors_rule` block supports the following:
 - `allowed_headers` - (Required) A list of headers that are allowed to be a part of the cross-origin request.
 - `allowed_methods` - (Required) A list of HTTP methods that are allowed to be executed by the origin. Valid options are `DELETE`, `GET`, `HEAD`, `MERGE`, `POST`, `OPTIONS`, `PUT` or `PATCH`.
 - `allowed_origins` - (Required) A list of origin domains that will be allowed by CORS.
 - `exposed_headers` - (Required) A list of response headers that are exposed to CORS clients.
 - `max_age_in_seconds` - (Required) The number of seconds the client should cache a preflight response.

 ---
 `diagnostic_settings` block supports the following:
 - `name` - (Optional) The name of the diagnostic setting. Defaults to `null`.
 - `log_categories` - (Optional) A set of log categories to enable. Defaults to an empty set.
 - `log_groups` - (Optional) A set of log groups to enable. Defaults to `["allLogs"]`.
 - `metric_categories` - (Optional) A set of metric categories to enable. Defaults to `["AllMetrics"]`.
 - `log_analytics_destination_type` - (Optional) The destination type for log analytics. Defaults to `"Dedicated"`.
 - `workspace_resource_id` - (Optional) The resource ID of the Log Analytics workspace. Defaults to `null`.
 - `resource_id` - (Optional) The resource ID of the target resource for diagnostics. Defaults to `null`.
 - `event_hub_authorization_rule_resource_id` - (Optional) The resource ID of the Event Hub authorization rule. Defaults to `null`.
 - `event_hub_name` - (Optional) The name of the Event Hub. Defaults to `null`.
 - `marketplace_partner_resource_id` - (Optional) The resource ID of the marketplace partner. Defaults to `null`.

 ---
 `retention_policy` block supports the following:
 - `days` - (Optional) Specifies the number of days that the `azurerm_shares` should be retained, between `1` and `365` days. Defaults to `7`.

EOT
}

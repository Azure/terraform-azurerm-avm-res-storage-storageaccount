variable "storage_account_queue_encryption_key_type" {
  type        = string
  default     = null
  description = "(Optional) The encryption type of the queue service. Possible values are `Service` and `Account`. Changing this forces a new resource to be created. Default value is `Service`."
}

variable "storage_account_queue_properties" {
  type = object({
    cors_rule = optional(list(object({
      allowed_headers    = list(string)
      allowed_methods    = list(string)
      allowed_origins    = list(string)
      exposed_headers    = list(string)
      max_age_in_seconds = number
    })))
    hour_metrics = optional(object({
      enabled               = bool
      include_apis          = optional(bool)
      retention_policy_days = optional(number)
      version               = string
    }))
    logging = optional(object({
      delete                = bool
      read                  = bool
      retention_policy_days = optional(number)
      version               = string
      write                 = bool
    }))
    minute_metrics = optional(object({
      enabled               = bool
      include_apis          = optional(bool)
      retention_policy_days = optional(number)
      version               = string
    }))
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
 `hour_metrics` block supports the following:
 - `enabled` - (Required) Indicates whether hour metrics are enabled for the Queue service.
 - `include_apis` - (Optional) Indicates whether metrics should generate summary statistics for called API operations.
 - `retention_policy_days` - (Optional) Specifies the number of days that logs will be retained.
 - `version` - (Required) The version of storage analytics to configure.

 ---
 `logging` block supports the following:
 - `delete` - (Required) Indicates whether all delete requests should be logged.
 - `read` - (Required) Indicates whether all read requests should be logged.
 - `retention_policy_days` - (Optional) Specifies the number of days that logs will be retained.
 - `version` - (Required) The version of storage analytics to configure.
 - `write` - (Required) Indicates whether all write requests should be logged.

 ---
 `minute_metrics` block supports the following:
 - `enabled` - (Required) Indicates whether minute metrics are enabled for the Queue service.
 - `include_apis` - (Optional) Indicates whether metrics should generate summary statistics for called API operations.
 - `retention_policy_days` - (Optional) Specifies the number of days that logs will be retained.
 - `version` - (Required) The version of storage analytics to configure.
EOT
}

variable "storage_queue" {
  type = map(object({
    metadata = optional(map(string))
    name     = string
    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
      read   = optional(string)
      update = optional(string)
    }))
  }))
  default     = {}
  description = <<-EOT
 - `metadata` - (Optional) A mapping of MetaData which should be assigned to this Storage Queue.
 - `name` - (Required) The name of the Queue which should be created within the Storage Account. Must be unique within the storage account the queue is located. Changing this forces a new resource to be created.

 ---
 `timeouts` block supports the following:
 - `create` - (Defaults to 30 minutes) Used when creating the Storage Queue.
 - `delete` - (Defaults to 30 minutes) Used when deleting the Storage Queue.
 - `read` - (Defaults to 5 minutes) Used when retrieving the Storage Queue.
 - `update` - (Defaults to 30 minutes) Used when updating the Storage Queue.
EOT
  nullable    = false
}

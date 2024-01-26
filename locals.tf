locals {
  blob_endpoint            = length(var.containers) == 0 ? [] : ["blob"]
  endpoints                = toset(concat(local.blob_endpoint, local.queue_endpoint, local.table_endpoint))
  private_endpoint_enabled = var.private_endpoints != null
  private_endpoints        = local.private_endpoint_enabled ? local.endpoints : toset([])
  queue_endpoint           = length(var.queues) == 0 ? [] : ["queue"]
  table_endpoint           = length(var.tables) == 0 ? [] : ["table"]

  location                           = var.location != null ? var.location : data.azurerm_resource_group.rg.location
  role_definition_resource_substring = "/providers/Microsoft.Authorization/roleDefinitions"

  # Private endpoint application security group associations
  private_endpoint_application_security_group_associations = { for assoc in flatten([
    for pe_k, pe_v in var.private_endpoints : [
      for asg_k, asg_v in pe_v.application_security_group_associations : {
        asg_key         = asg_k
        pe_key          = pe_k
        asg_resource_id = asg_v
      }
    ]
  ]) : "${assoc.pe_key}-${assoc.asg_key}" => assoc }

}

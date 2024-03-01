locals {
  blob_endpoint = length(var.containers) == 0 ? [] : ["blob"]
  # Role assignments for containers
  containers_role_assignments = { for ra in flatten([
    for ck, cv in var.containers : [
      for rk, rv in cv.role_assignments : {
        container_key   = ck
        ra_key          = rk
        role_assignment = rv
      }
    ]
  ]) : "${ra.container_key}-${ra.ra_key}" => ra }
  endpoints = toset(concat(local.blob_endpoint, local.queue_endpoint, local.table_endpoint))
  location  = var.location != null ? var.location : data.azurerm_resource_group.rg.location
  # private endpoint role assignments
  pe_role_assignments = { for ra in flatten([
    for pe_k, pe_v in var.private_endpoints : [
      for rk, rv in pe_v.role_assignments : {
        private_endpoint_key = pe_k
        ra_key               = rk
        role_assignment      = rv
      }
    ]
  ]) : "${ra.private_endpoint_key}-${ra.ra_key}" => ra }
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
  private_endpoint_enabled = var.private_endpoints != null
  private_endpoints        = local.private_endpoint_enabled ? local.endpoints : toset([])
  queue_endpoint           = length(var.queues) == 0 ? [] : ["queue"]
  # Role assignments for queues
  queues_role_assignments = { for ra in flatten([
    for qk, qv in var.queues : [
      for rk, rv in qv.role_assignments : {
        queue_key       = qk
        ra_key          = rk
        role_assignment = rv
      }
    ]
  ]) : "${ra.queue_key}-${ra.ra_key}" => ra }
  role_definition_resource_substring = "/providers/Microsoft.Authorization/roleDefinitions"
  # Role assignments for shares
  shares_role_assignments = { for ra in flatten([
    for sk, sv in var.shares : [
      for rk, rv in sv.role_assignments : {
        share_key       = sk
        ra_key          = rk
        role_assignment = rv
      }
    ]
  ]) : "${ra.share_key}-${ra.ra_key}" => ra }
  table_endpoint = length(var.tables) == 0 ? [] : ["table"]
  # Role assignments for tables
  tables_role_assignments = { for ra in flatten([
    for tk, tv in var.tables : [
      for rk, rv in tv.role_assignments : {
        table_key       = tk
        ra_key          = rk
        role_assignment = rv
      }
    ]
  ]) : "${ra.table_key}-${ra.ra_key}" => ra }
}


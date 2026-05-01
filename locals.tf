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
  # Private endpsoint application security group associations
  private_endpoint_application_security_group_associations = { for assoc in flatten([
    for pe_k, pe_v in var.private_endpoints : [
      for asg_k, asg_v in pe_v.application_security_group_associations : {
        asg_key         = asg_k
        pe_key          = pe_k
        asg_resource_id = asg_v
      }
    ]
  ]) : "${assoc.pe_key}-${assoc.asg_key}" => assoc }
  queue_endpoint = length(var.queues) == 0 ? [] : ["queue"]
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

locals {
  has_management_policy = length(var.storage_management_policy_rule) > 0

  # Azure expands the special "AllMetrics" category to individual metric categories
  # ("Capacity" and "Transaction") for storage sub-resources. Pre-expanding here
  # prevents perpetual plan diffs caused by the mismatch between the configured
  # "AllMetrics" value and what Azure returns when reading the resource state.
  _diag_sub_resource_metric_inputs = {
    blob  = { for k, v in var.diagnostic_settings_blob : k => v.metric_categories }
    file  = { for k, v in var.diagnostic_settings_file : k => v.metric_categories }
    queue = { for k, v in var.diagnostic_settings_queue : k => v.metric_categories }
    table = { for k, v in var.diagnostic_settings_table : k => v.metric_categories }
  }
  _diag_sub_resource_metric_expanded = {
    for type_key, settings in local._diag_sub_resource_metric_inputs : type_key => {
      for k, metric_cats in settings : k => toset(flatten([
        for cat in coalesce(metric_cats, []) : cat == "AllMetrics" ? ["Capacity", "Transaction"] : [cat]
      ]))
    }
  }
  blob_diagnostic_metric_categories  = local._diag_sub_resource_metric_expanded["blob"]
  file_diagnostic_metric_categories  = local._diag_sub_resource_metric_expanded["file"]
  queue_diagnostic_metric_categories = local._diag_sub_resource_metric_expanded["queue"]
  table_diagnostic_metric_categories = local._diag_sub_resource_metric_expanded["table"]
}


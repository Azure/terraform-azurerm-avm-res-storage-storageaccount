locals {
  has_management_policy = length(var.storage_management_policy_rule) > 0
}

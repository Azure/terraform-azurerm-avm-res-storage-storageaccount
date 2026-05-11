locals {
  permission_string = var.permission_scope == null ? null : [
    for ps in var.permission_scope : {
      service      = ps.service
      resourceName = ps.resource_name
      permissions = join("", concat(
        ps.permissions.read == true ? ["r"] : [],
        ps.permissions.write == true ? ["w"] : [],
        ps.permissions.delete == true ? ["d"] : [],
        ps.permissions.list == true ? ["l"] : [],
        ps.permissions.create == true ? ["c"] : [],
      ))
    }
  ]
  ssh_keys = var.ssh_authorized_key == null ? null : [
    for k in var.ssh_authorized_key : {
      description = k.description
      key         = k.key
    }
  ]
  tracing_headers = var.tracing_tags_header == null ? null : { "User-Agent" = var.tracing_tags_header }
}

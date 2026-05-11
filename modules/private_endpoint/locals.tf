locals {
  asg_body = [
    for k, v in var.application_security_group_resource_ids : { id = v }
  ]
  ip_configurations_body = [
    for k, v in var.ip_configurations : {
      name = v.name
      properties = {
        groupId          = var.subresource_name
        memberName       = var.subresource_name
        privateIPAddress = v.private_ip_address
      }
    }
  ]
  tracing_headers = var.tracing_tags_header == null ? null : { "User-Agent" = var.tracing_tags_header }
}

variable "key_vault_firewall_bypass_ip_cidr" {
  type    = string
  default = null
}

variable "location" {
  type    = string
  default = "westeurope"
}

variable "managed_identity_principal_id" {
  type    = string
  default = null
}

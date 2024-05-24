variable "bypass_ip_cidr" {
  type        = string
  default     = null
  description = "value to bypass the IP CIDR on firewall rules"
}

variable "msi_id" {
  type        = string
  default     = null
  description = "If you're running this example by authentication with identity, please set identity object id here."
}

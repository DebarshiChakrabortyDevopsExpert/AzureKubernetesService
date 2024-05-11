variable "virtual_networks" {}

variable "network_ddos_protection_plan" {
  type        = any
  description = "Network network ddos protection plan parameters."
  default     = []
}
variable "pm_api_url" {}
variable "pm_api_token_id" {}
variable "pm_api_token_secret" {}
variable "pm_password" {}

variable "target_node" {
  default = "pve"
}

variable "ct_name" {
  default = "ubuntu-lxc"
}

variable "ct_password" {
  default = "ubuntu123"
}

variable "ct_cores" {
  default = 2
}

variable "ct_memory" {
  default = 1024
}

variable "ct_disk" {
  default = 10
}

variable "ct_template" {
  default = "local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
}
provider "kubernetes" {
  # When no host is specified this provider reads ~./kube/config
}

module "um-login-service" {
  source = "../global/um-login-service"
  hostname = var.hostname
}

output "lb_address" {
  value = module.um-login-service.lb_address
}

variable "hostname" {
  type = string
}

module "proc-ades" {
  source = "../global/proc-ades"
  dh_user_email = var.dh_user_email
  dh_user_name = var.dh_user_name
  dh_user_password = var.dh_user_password
}

variable "dh_user_email" {
  type = string
  default = "somebody@github.com"
}

variable "dh_user_name" {
  type = string
  default = "username"
}

variable "dh_user_password" {
  type = string
  default = "password"
}

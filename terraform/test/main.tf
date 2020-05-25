provider "kubernetes" {
  # When no host is specified this provider reads ~./kube/config
}

module "um-login-service" {
  source = "../global/um-login-service"
  nginx_ip = var.nginx_ip
  hostname = var.hostname
}

variable "nginx_ip" {
  type = string
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

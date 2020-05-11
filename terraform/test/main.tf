provider "kubernetes" {
  # When no host is specified this provider reads ~./kube/config
}

module "um-login-service" {
  source = "../global/um-login-service"
  nginx_ip = var.nginx_ip
}

variable "nginx_ip" {
  type = string
}

module "proc-ades" {
  source = "../global/proc-ades"
}
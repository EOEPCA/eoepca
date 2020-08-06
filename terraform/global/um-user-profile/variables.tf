variable "nginx_ip" {
  type = string
}

variable "hostname" {
  type = string
}

variable "module_depends_on" {
  type = any
}

output "um-user-profile-up" {
  value      = true
  depends_on = [kubernetes_service.user-profile]
}

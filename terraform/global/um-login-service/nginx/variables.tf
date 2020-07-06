variable "nginx_ip" {
    type = string
}

variable "hostname" {
    type = string
}

variable "module_depends_on" {
  type = any
}

output "nginx-done" {
  value = true
  depends_on = [ kubernetes_ingress.gluu_ingress_scim_configuration ]
}
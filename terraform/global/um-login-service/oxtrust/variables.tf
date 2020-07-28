variable "nginx_ip" {
    type = string
}

variable "hostname" {
    type = string
}

variable "module_depends_on" {
  type = any
}

output "oxtrust-up" {
  value = true
  depends_on = [ kubernetes_service.oxtrust ]
}
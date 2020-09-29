variable "module_depends_on" {
  type = any
}

variable "hostname" {
    type = string
}

output "rm-data-access-up" {
  value = true
  depends_on = [ kubernetes_service.data-access ]
}

variable "nginx_ip" {
    type = string
}

variable "hostname" {
    type = string
}

output "config-done" {
  value = true
  depends_on = [ kubernetes_service.pdp-engine ]
}
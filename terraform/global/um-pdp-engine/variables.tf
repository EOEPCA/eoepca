variable "nginx_ip" {
    type = string
    default = "0.0.0.0"
} 

variable "hostname" {
    type = string
    default = "test.eoepca.org"
}

variable "module_depends_on" {
  type = any
}

output "um-pdp-engine-up" {
  value      = true
  depends_on = [module.config]
}

variable "nginx_ip" {
  type    = string
  default = "0.0.0.0"
}

variable "hostname" {
  type    = string
  default = "test.192.168.123.110.nip.io"
}

variable "module_depends_on" {
  type = any
}

output "um-user-profile-up" {
  value      = module.config.um-user-profile-up
  depends_on = [module.config]
}

variable "hostname" {
  type    = string
  default = "test.185.52.192.60.nip.io"
}

variable "config_file" {
  type = string
}

output "um-login-service-up" {
  value      = true
  depends_on = [module.config, module.ldap, module.nginx, module.oxauth, module.oxtrust, module.oxpassport]
}

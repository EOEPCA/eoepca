variable "hostname" {
  type    = string
  default = "test.10.0.2.15.nip.io"
}

variable "config_file" {
  type = string
}

output "um-login-service-up" {
  value      = true
  depends_on = [module.config, module.ldap, module.nginx, module.oxauth, module.oxtrust, module.oxpassport]
}

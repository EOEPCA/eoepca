variable "hostname" {
    type = string
    default = "test.eoepca.org"
}

variable "config_file" {
  type = string
}

output "um-login-service-up" {
  value = true
  depends_on = [ module.config, module.ldap, module.nginx, module.oxauth, module.oxtrust, module.oxpassport ]
}
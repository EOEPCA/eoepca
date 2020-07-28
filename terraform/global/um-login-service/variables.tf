variable "hostname" {
  type    = string
}

variable "nginx_ip" {
    type = string
}

variable "config_file" {
  type = string
}

output "um-login-service-up" {
  value      = true
  depends_on = [module.config, module.ldap, module.nginx, module.oxauth, module.oxtrust, module.oxpassport]
}

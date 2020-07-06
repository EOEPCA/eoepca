variable "module_depends_on" {
  type = any
}

output "ldap-up" {
  value = true
  depends_on = [ kubernetes_service.opendj, kubernetes_job.um_login_persistence ]
}
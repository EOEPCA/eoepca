variable "wspace_user_name" {
  type = string
  default = "username"
}

variable "wspace_user_password" {
  type = string
  default = "password"
}

variable "module_depends_on" {
  type = any
}

variable "hostname" {
    type = string
}

output "rm-workspace-up" {
  value = true
  depends_on = [ kubernetes_service.workspace ]
}
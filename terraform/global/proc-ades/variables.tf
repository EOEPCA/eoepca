variable "dh_user_email" {
  type = string
  default = "somebody@github.com"
}

variable "dh_user_name" {
  type = string
  default = "username"
}

variable "dh_user_password" {
  type = string
  default = "password"
}

variable "wspace_user_name" {
  type = string
  default = "username"
}

variable "wspace_user_password" {
  type = string
  default = "password"
}

variable module_depends_on {
  type = any
}

output "proc-ades-up" {
  value = true
}
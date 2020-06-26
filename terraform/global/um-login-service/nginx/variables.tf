variable "nginx_ip" {
    type = string
}

variable "hostname" {
    type = string
}

variable "module_depends_on" {
  type = any
}

output "nginx-done" {
  value = true
}
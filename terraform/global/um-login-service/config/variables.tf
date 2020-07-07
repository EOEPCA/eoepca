variable "nginx_ip" {
    type = string
}

variable "hostname" {
    type = string
}

variable "config_file" {
  type = string
}

output "config-done" {
  value = true
  depends_on = [ kubernetes_job.config_init_load_job ]
}
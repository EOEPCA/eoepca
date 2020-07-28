# Apply User Profile
module "config" {
  source   = "./config"
  nginx_ip = var.nginx_ip
  hostname = var.hostname
  config_module_depends_on = [ var.module_depends_on ]
}

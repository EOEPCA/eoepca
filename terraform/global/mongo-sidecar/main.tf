# Apply Mongo Sidecar
module "config" {
  source   = "./config"
  nginx_ip = var.nginx_ip
  hostname = var.hostname
}

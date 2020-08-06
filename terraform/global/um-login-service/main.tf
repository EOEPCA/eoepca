
# resource "google_dns_managed_zone" "test" {
#   name     = "test-zone"
#   dns_name = join("", [var.hostname, "."])
# }

# resource "google_dns_record_set" "test" {
#   name = "${google_dns_managed_zone.test.dns_name}"
#   type = "A"
#   ttl  = 300

#   managed_zone = google_dns_managed_zone.test.name

#   rrdatas = [var.nginx_ip]
# }


# Apply config
module "config" {
  source      = "./config"
  nginx_ip    = var.nginx_ip
  hostname    = var.hostname
  config_file = var.config_file
}

# Apply LDAP
module "ldap" {
  source            = "./ldap"
  module_depends_on = [module.config.config-done]
}

# Enable Ingress
module "nginx" {
  source            = "./nginx"
  nginx_ip          = var.nginx_ip
  hostname          = var.hostname
  module_depends_on = [module.config.config-done]
}

module "oxauth" {
  source            = "./oxauth"
  nginx_ip          = var.nginx_ip
  hostname          = var.hostname
  module_depends_on = [module.nginx.nginx-done, module.ldap.ldap-up, module.config.config-done]
}

module "oxtrust" {
  source            = "./oxtrust"
  nginx_ip          = var.nginx_ip
  hostname          = var.hostname
  module_depends_on = [module.oxauth.oxauth-up]
}

module "oxpassport" {
  source            = "./oxpassport"
  nginx_ip          = var.nginx_ip
  hostname          = var.hostname
  module_depends_on = [module.oxauth.oxauth-up, module.oxtrust.oxtrust-up]
}

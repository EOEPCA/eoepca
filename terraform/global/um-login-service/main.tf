# Install NGINX ingress controller

module "ingress" {
  source  = "skydome/ingress/kubernetes"
  version = "0.0.4"
  namespaces = [ "default" ]
  replicacount = 1
}

output "lb_address" {
  value = module.ingress.load_balancer_ip
  depends_on = [ module.config, module.ldap, module.nginx, module.oxauth, module.oxpassport, module.oxtrust ]
}

# resource "google_dns_managed_zone" "test" {
#   name     = "test-zone"
#   dns_name = "test.eoepca.org."
# }

# resource "google_dns_record_set" "test" {
#   name = "${google_dns_managed_zone.test.dns_name}"
#   type = "A"
#   ttl  = 300

#   managed_zone = google_dns_managed_zone.test.name

#   rrdatas = [module.nginx-ingress-controller.lb_address]
# }


# Apply config
module "config" {
  source   = "./config"
  nginx_ip = module.ingress.load_balancer_ip[0]
  hostname = var.hostname
  config_file = var.config_file
}

# Apply LDAP
module "ldap" {
 source = "./ldap"
 module_depends_on = [ module.ingress.load_balancer_ip, module.config.config-done ]
}

# Enable Ingress
module "nginx" {
 source   = "./nginx"
 nginx_ip = module.ingress.load_balancer_ip[0] 
 hostname = var.hostname
 module_depends_on = [ module.ingress.load_balancer_ip, module.ldap.ldap-up ]
}

module "oxauth" {
 source   = "./oxauth"
 nginx_ip = module.ingress.load_balancer_ip[0] 
 hostname = var.hostname
 module_depends_on = [ module.ingress.load_balancer_ip, module.nginx.nginx-done, module.ldap.ldap-up, module.config.config-done ]
}

module "oxtrust" {
   source = "./oxtrust"
   nginx_ip = module.ingress.load_balancer_ip[0] 
   hostname = var.hostname
   module_depends_on = [ module.oxauth.oxauth-up ]
}

module "oxpassport" {
   source = "./oxpassport"
   nginx_ip = module.ingress.load_balancer_ip[0] 
   hostname = var.hostname
   module_depends_on = [ module.oxauth.oxauth-up, module.oxtrust.oxtrust-up ]
}
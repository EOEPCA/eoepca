# Install NGINX ingress controller

module "nginx-ingress-controller" {
  source  = "byuoitav/nginx-ingress-controller/kubernetes"
  version = "0.1.13"
}

output "lb_address" {
  value = module.nginx-ingress-controller.lb_address
}


# Apply config
module "config" {
  source   = "./config"
  nginx_ip = module.nginx-ingress-controller.lb_address
  hostname = var.hostname
}

# Apply LDAP
module "ldap" {
 source = "./ldap"
 module_depends_on = [ module.nginx-ingress-controller.lb_address, module.config.config-done ]
}

# Enable Ingress
module "nginx" {
 source   = "./nginx"
 nginx_ip = module.nginx-ingress-controller.lb_address 
 hostname = var.hostname
 module_depends_on = [ module.nginx-ingress-controller.lb_address, module.ldap.ldap-up ]
}

module "oxauth" {
 source   = "./oxauth"
 nginx_ip = module.nginx-ingress-controller.lb_address 
 hostname = var.hostname
 module_depends_on = [ module.nginx-ingress-controller.lb_address, module.nginx.nginx-done, module.ldap.ldap-up, module.config.config-done ]
}

module "oxtrust" {
   source = "./oxtrust"
   nginx_ip = module.nginx-ingress-controller.lb_address 
   hostname = var.hostname
   module_depends_on = [ module.oxauth.oxauth-up ]
}

module "oxpassport" {
   source = "./oxpassport"
   nginx_ip = module.nginx-ingress-controller.lb_address 
   hostname = var.hostname
   module_depends_on = [ module.oxauth.oxauth-up, module.oxtrust.oxtrust-up ]
}
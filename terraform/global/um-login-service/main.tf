# Apply config
module "config" {
  source = "./config"
}

# Apply LDAP
module "ldap" {
    source = "./ldap"
}

# Enable Ingress
module "nginx" {
    source = "./nginx"
    nginx_ip = var.nginx_ip
    hostname = var.hostname
}

module "oxauth" {
    source = "./oxauth"
    nginx_ip = var.nginx_ip
    hostname = var.hostname
}

# module "oxtrust" {
#     source = "./oxtrust"
#     nginx_ip = var.nginx_ip
#     hostname = var.hostname
# }

# module "oxpassport" {
#     source = "./oxpassport"
#     nginx_ip = var.nginx_ip
#     hostname = var.hostname
# }
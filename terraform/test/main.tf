provider "kubernetes" {
  # When no host is specified this provider reads ~./kube/config
}

# module "um-login-service" {
#   source = "../global/um-login-service"
#   nginx_ip = var.nginx_ip
#   hostname = var.hostname
# }

# module "um-pep-engine" {
#   source = "../global/um-pep-engine"
#   nginx_ip = var.nginx_ip
#   hostname = var.hostname
# }

# module "um-user-profile" {
#   source = "../global/um-user-profile"
#   nginx_ip = var.nginx_ip
#   hostname = var.hostname
# }  

module "proc-ades" {
  source = "../global/proc-ades"
  dh_user_email = var.dh_user_email
  dh_user_name = var.dh_user_name
  dh_user_password = var.dh_user_password
  wspace_user_name = var.wspace_user_name
  wspace_user_password = var.wspace_user_password
}

provider "kubernetes" {
  # When no host is specified this provider reads ~./kube/config
  version = "~> 1.12"
  config_path = var.kube_config_path
}

provider "kubectl" {
}

resource "kubernetes_role_binding" "default_admin" {
  metadata {
    name = "default-admin"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "default"
    namespace = "default"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "admin"
  }
}

module "nfs-provisioner" {
  source             = "../global/nfs-provisioner"
  nfs_server_address = var.nfs_server_address
}

module "storage" {
  source             = "../global/storage"
  nfs_server_address = var.nfs_server_address
  storage_class      = var.storage_class
}

# module "um-login-service" {
#   source      = "../global/um-login-service"
#   nginx_ip    = var.public_ip
#   hostname    = var.hostname
#   config_file = var.um-login-config_file
# }

# module "um-pep-engine" {
#   source            = "../global/um-pep-engine"
#   nginx_ip          = var.public_ip
#   hostname          = var.hostname
#   module_depends_on = [module.um-login-service.um-login-service-up]
# }

# module "um-pdp-engine" {
#   source            = "../global/um-pdp-engine"
#   nginx_ip          = var.public_ip
#   hostname          = var.hostname
#   module_depends_on = [module.um-login-service.um-login-service-up]
# }

# module "um-user-profile" {
#   source            = "../global/um-user-profile"
#   nginx_ip          = var.public_ip
#   hostname          = var.hostname
#   module_depends_on = [module.um-login-service.um-login-service-up]
# }

# module "proc-ades" {
#   source               = "../global/proc-ades"
#   dh_user_email        = var.dh_user_email
#   dh_user_name         = var.dh_user_name
#   dh_user_password     = var.dh_user_password
#   wspace_user_name     = var.wspace_user_name
#   wspace_user_password = var.wspace_user_password
#   hostname             = var.hostname
#   module_depends_on    = []
# }

module "rm-workspace" {
  source               = "../global/rm-workspace"
  wspace_user_name     = var.wspace_user_name
  wspace_user_password = var.wspace_user_password
  hostname             = var.hostname
  module_depends_on    = []
}

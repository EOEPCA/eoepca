provider "kubernetes" {
  # When no host is specified this provider reads ~./kube/config
}

module "template-svce" {
  source = "../global/template-svce"
  db_username = var.db_username
  db_password = var.db_password
}


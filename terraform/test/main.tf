variable "db_username" {
  type = string
  default = "an_user"
}

variable "db_password" {
  type = string
  default = "a_password"
}

provider "kubernetes" {
  # When no host is specified this provider reads ~./kube/config
  load_config_file = "false"

  host = "localhost"
}

module "template-svce" {
  source = "../global/template-svce"
  db_username = var.db_username
  db_password = var.db_password
}

resource "kubernetes_secret" "db-user-pass" {
  metadata {
    name = "db-user-pass"
    namespace = "eo-services"
  }

  data = {
    username = var.db_username
    password = var.db_password
  }

  type = "kubernetes.io/basic-auth"
}

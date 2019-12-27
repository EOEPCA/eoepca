resource "kubernetes_secret" "db-user-pass" {
  metadata {
    name = "db-user-pass"
    namespace = "eo-services"
  }

  data = {
    db_username = var.db_username
    db_password = var.db_password
  }

  type = "kubernetes.io/basic-auth"
}

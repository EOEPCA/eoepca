resource "kubernetes_secret" "db-user-pass" {
  metadata {
    name = "db-user-pass"
    namespace = "eo-services"
  }

  data = {
    db_username = "admin"
    db_password = "P4ssw0rd"
  }

  type = "kubernetes.io/basic-auth"
}

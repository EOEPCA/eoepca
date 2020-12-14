resource "kubernetes_ingress" "user_profile" {
  metadata {
    name = "user-profile"
  }

  spec {
    rule {
      host = join(".", ["profile", var.hostname])

      http {
        path {
          backend {
            service_name = "user-profile"
            service_port = "5566"
          }
        }
      }
    }
  }
}

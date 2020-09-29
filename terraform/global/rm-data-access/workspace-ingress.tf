resource "kubernetes_ingress" "data-access" {
  metadata {
    name = "data-access"
  }

  spec {
    rule {
      host = join(".", ["data-access", var.hostname])

      http {
        path {
          backend {
            service_name = "data-access"
            service_port = "80"
          }
        }
      }
    }
  }
}

resource "kubernetes_ingress" "ades" {
  metadata {
    name = "ades"
  }

  spec {
    rule {
      host = join(".", ["ades", var.hostname])

      http {
        path {
          backend {
            service_name = "pep-engine"
            service_port = "5566"
          }
        }
      }
    }
  }
}


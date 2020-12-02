resource "kubernetes_ingress" "pdp" {
  metadata {
    name = "pdp"
  }

  spec {
    rule {
      host = join(".", ["pdp", var.hostname])

      http {
        path {
          backend {
            service_name = "pdp-engine"
            service_port = "5567"
          }
        }
      }
    }
  }
}

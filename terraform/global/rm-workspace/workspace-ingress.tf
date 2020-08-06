resource "kubernetes_ingress" "workspace" {
  metadata {
    name = "workspace"
  }

  spec {
    rule {
      host = join(".", ["workspace", var.hostname])

      http {
        path {
          backend {
            service_name = "workspace"
            service_port = "80"
          }
        }
      }
    }
  }
}

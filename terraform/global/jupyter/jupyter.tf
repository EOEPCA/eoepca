resource "kubernetes_deployment" "jupyter" {
  metadata {
    name = "jupyter"

    labels = {
      app = "jupyter"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "jupyter"
      }
    }

    template {
      metadata {
        labels = {
          app = "jupyter"
        }
      }

      spec {
        container {
          name  = "jupyter"
          image = "rconway/jupyter"
        }
      }
    }
  }
}

resource "kubernetes_service" "jupyter" {
  metadata {
    name = "jupyter"

    labels = {
      app = "jupyter"
    }
  }

  spec {
    port {
      protocol    = "TCP"
      port        = 80
      target_port = "8888"
    }

    selector = {
      app = "jupyter"
    }

    type = "NodePort"
  }
}

resource "kubernetes_ingress" "jupyter" {
  metadata {
    name      = "jupyter"
    namespace = "default"
  }

  spec {
    rule {
      host = join(".", ["jupyter", var.hostname])

      http {
        path {
          backend {
            service_name = "jupyter"
            service_port = "80"
          }
        }
      }
    }
  }
}

resource "kubernetes_deployment" "ades" {
  metadata {
    name = "ades"

    labels = {
      app = "ades"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "ades"
      }
    }

    template {
      metadata {
        labels = {
          app = "ades"
        }
      }

      spec {
        container {
          name  = "ades"
          image = "eoepca/proc-ades:localkube"
        }

        container {
          name  = "kubeproxy"
          image = "eoepca/kubeproxy"
        }
      }
    }
  }
}

resource "kubernetes_service" "ades" {
  metadata {
    name = "ades"

    labels = {
      app = "ades"
    }
  }

  spec {
    port {
      protocol    = "TCP"
      port        = 80
      target_port = "80"
    }

    selector = {
      app = "ades"
    }

    type = "NodePort"
  }
}


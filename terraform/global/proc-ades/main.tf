resource "kubernetes_deployment" "ades" {
  metadata {
    name = "ades"

    labels = {
      app = "ades"
    }
  }
  depends_on = [null_resource.waitfor-module-depends]

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
        volume {
          name = "config"

          config_map {
            name = "ades-argo"
          }
        }

        container {
          name  = "ades"
          image = "rconway/proc-ades:v0.1"
          # image = "rconway/requestlogger"

          volume_mount {
            name       = "config"
            mount_path = "/opt/t2config/"
          }
        }

        container {
          name  = "kubeproxy"
          image = "eoepca/kubeproxy"
        }

        automount_service_account_token = true
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
  depends_on = [kubernetes_deployment.ades]

  spec {
    port {
      protocol    = "TCP"
      port        = 80
      target_port = "80"
      node_port   = 32746
    }

    selector = {
      app = "ades"
    }

    type = "NodePort"
  }
}


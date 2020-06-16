resource "kubernetes_service" "eoepca-ades-core" {
  metadata {
    name = "eoepca-ades-core"
  }
  spec {

    selector = {
      app  = "eoepca-ades-core"
      tier = "service"
    }

    port {
      port        = 80
      target_port = 80
      name        = "http"
      protocol    = "TCP"
    }

    cluster_ip = "None"
  }
}

resource "kubernetes_deployment" "eoepca-ades-core-deployment" {
  metadata {
    name      = "eoepca-ades-core-deployment"
  }

  spec {
    selector {
      match_labels = {
        app  = "eoepca-ades-core"
        tier = "service"
      }
    }

    replicas = 1

    template {
      metadata {
        labels = {
          app  = "eoepca-ades-core"
          tier = "service"
        }
      }

      spec {
        image_pull_secrets {
          name = "dockerhub-imagepullsecret"
        }
        container {
          image = "eoepca/eoepca-ades-core:travis_develop_25"
          name  = "eoepca-ades-core"
          port {
            container_port = 7777
          }
        }
      }
    }
  }
}

resource "kubernetes_deployment" "ades" {
  metadata {
    name = "ades"

    labels = {
      app = "ades"
    }
  }
  depends_on = [ var.module_depends_on, null_resource.waitfor-login-service ]

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
        automount_service_account_token = true

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
  depends_on = [ var.module_depends_on, null_resource.waitfor-login-service ]

  spec {
    port {
      protocol    = "TCP"
      port        = 80
      target_port = 80
      node_port = 32746
    }

    selector = {
      app = "ades"
    }

    type = "NodePort"
  }
}


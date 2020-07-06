resource "kubernetes_deployment" "workspace" {
  metadata {
    name = "workspace"

    labels = {
      app = "workspace"
    }
  }
  depends_on = [ var.module_depends_on, null_resource.waitfor-login-service ]

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "workspace"
      }
    }

    template {
      metadata {
        labels = {
          app = "workspace"
        }
      }

      spec {
        volume {
          name = "vol-workspace-pvc"

          persistent_volume_claim {
            claim_name = "workspace-pvc"
          }
        }

        container {
          name  = "nextcloud"
          image = "nextcloud:19"

          env {
            name = "SQLITE_DATABASE"
          }

          env {
            name  = "NEXTCLOUD_ADMIN_USER"
            value = var.wspace_user_name
          }

          env {
            name  = "NEXTCLOUD_ADMIN_PASSWORD"
            value = var.wspace_user_password
          }

          env {
            name  = "NEXTCLOUD_TRUSTED_DOMAINS"
            value = "\"*\""
          }

          volume_mount {
            name       = "vol-workspace-pvc"
            mount_path = "/var/www/html"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "workspace" {
  metadata {
    name = "workspace"

    labels = {
      app = "workspace"
    }
  }
  depends_on = [ var.module_depends_on, null_resource.waitfor-login-service ]

  spec {
    port {
      protocol    = "TCP"
      port        = 80
      target_port = "80"
    }

    selector = {
      app = "workspace"
    }

    type = "NodePort"
  }
}

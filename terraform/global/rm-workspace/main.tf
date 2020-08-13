resource "kubernetes_deployment" "workspace" {
  metadata {
    name = "workspace"

    labels = {
      app = "workspace"
    }
  }
  depends_on = [null_resource.waitfor-module-depends]

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
          name = "vol-resman"

          persistent_volume_claim {
            claim_name = "eoepca-resman-pvc"
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
            name       = "vol-resman"
            mount_path = "/var/www/html"
            sub_path   = "workspace"
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
  depends_on = [kubernetes_deployment.workspace]

  spec {
    port {
      protocol    = "TCP"
      port        = 80
      target_port = "80"
      node_port   = "31999"
    }

    selector = {
      app = "workspace"
    }

    type = "NodePort"
  }

  provisioner "local-exec" {
    command = <<-EOT
      interval=$(( 5 ))
      msgInterval=$(( 30 ))
      step=$(( msgInterval / interval ))
      count=$(( 0 ))
      until kubectl logs service/workspace 2>/dev/null | grep "resuming normal operations" >/dev/null 2>&1
      do
        test $(( count % step )) -eq 0 && echo "Waiting for service/workspace"
        sleep $interval
        count=$(( count + interval ))
      done
      EOT
  }
}

resource "kubernetes_job" "config_init_load_job" {
  metadata {
    name = "config-init-load-job"
  }
  depends_on = [kubernetes_config_map.config-cm]

  spec {
    template {
      metadata {}

      spec {
        volume {
          name = "config-cm"

          config_map {
            name = "config-cm"
          }
        }

        automount_service_account_token = true

        container {
          name  = "config-init-load"
          image = "gluufederation/config-init:4.1.1_02"
          args  = ["load"]

          env_from {
            config_map_ref {
              name = "config-cm"
            }
          }

          env {
            name  = "GLUU_CONFIG_ADAPTER"
            value = "kubernetes"
          }

          env {
            name  = "GLUU_SECRET_ADAPTER"
            value = "kubernetes"
          }

          volume_mount {
            name              = "config-cm"
            mount_path        = "/opt/config-init/db/generate.json"
            sub_path          = "generate.json"
            mount_propagation = "HostToContainer"
          }
        }

        restart_policy = "Never"
      }
    }
  }
  wait_for_completion = true
  timeouts {
    create = "5m"
    update = "5m"
  }
}

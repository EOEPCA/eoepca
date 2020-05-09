resource "kubernetes_job" "config_init_load_job" {
  metadata {
    name = "config-init-load-job"
  }

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
            name       = "config-cm"
            mount_path = "/opt/config-init/db/generate.json"
            sub_path   = "generate.json"
          }
        }

        restart_policy = "Never"
      }
    }
  }
}


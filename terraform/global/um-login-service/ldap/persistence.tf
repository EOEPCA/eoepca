resource "kubernetes_job" "um_login_persistence" {
  metadata {
    name = "um-login-persistence"
  }

  depends_on = [null_resource.waitfor-module-depends, kubernetes_stateful_set.opendj_init]

  spec {
    backoff_limit = 1

    template {
      metadata {}

      spec {
        automount_service_account_token = true

        container {
          name  = "um-login-persistence"
          image = "eoepca/um-login-persistence:v0.2"

          env {
            name  = "GLUU_CONFIG_ADAPTER"
            value = "kubernetes"
          }

          env {
            name  = "GLUU_SECRET_ADAPTER"
            value = "kubernetes"
          }

          env {
            name  = "GLUU_PASSPORT_ENABLED"
            value = "true"
          }

          env {
            name  = "GLUU_LDAP_URL"
            value = "opendj:1636"
          }

          env {
            name  = "GLUU_PERSISTENCE_TYPE"
            value = "ldap"
          }

          env {
            name  = "GLUU_OXTRUST_CONFIG_GENERATION"
            value = "false"
          }

          env {
            name  = "GLUU_CACHE_TYPE"
            value = "NATIVE_PERSISTENCE"
          }

          env {
            name  = "LP_CLIENT_ID"
            value = "59f1fed27153f631bc08"
          }

          env {
            name  = "LP_CLIENT_SECRET"
            value = "640baffac0948454c48de2505726f53d11adc8a6"
          }

          image_pull_policy = "Always"
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

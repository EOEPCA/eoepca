resource "kubernetes_job" "um_login_persistence" {
  metadata {
    name = "um-login-persistence"
  }

  spec {
    backoff_limit = 1

    template {
      metadata {}

      spec {
        container {
          name  = "um-login-persistence"
          image = "eoepca/um-login-persistence:latest"

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

          image_pull_policy = "Always"
        }

        restart_policy = "Never"
      }
    }
  }
}


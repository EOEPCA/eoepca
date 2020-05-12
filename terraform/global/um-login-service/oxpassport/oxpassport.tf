resource "kubernetes_config_map" "oxpassport_cm" {
  metadata {
    name = "oxpassport-cm"
  }

  data = {
    DOMAIN = var.hostname
    GLUU_CONFIG_ADAPTER = "kubernetes"
    GLUU_LDAP_URL = "opendj:1636"
    GLUU_MAX_RAM_FRACTION = "1"
    GLUU_SECRET_ADAPTER = "kubernetes"
  }
}

resource "kubernetes_service" "oxpassport" {
  metadata {
    name = "oxpassport"

    labels = {
      app = "oxpassport"
    }
  }

  spec {
    port {
      name = "oxpassport"
      port = 8090
    }

    selector = {
      app = "oxpassport"
    }
  }
}

resource "kubernetes_deployment" "oxpassport" {
  metadata {
    name = "oxpassport"

    labels = {
      app = "oxpassport"
    }
  }

  timeouts {
    create = "5m"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "oxpassport"
      }
    }

    template {
      metadata {
        labels = {
          app = "oxpassport"
        }
      }

      spec {
        automount_service_account_token = true

        container {
          
          name  = "oxpassport"
          image = "gluufederation/oxpassport:4.1.1_01"

          port {
            container_port = 8090
          }

          env_from {
            config_map_ref {
              name = "oxpassport-cm"
            }
          }

          liveness_probe {
            http_get {
              path = "/passport"
              port = "8090"
            }

            initial_delay_seconds = 30
            period_seconds        = 30
          }

          readiness_probe {
            http_get {
              path = "/passport"
              port = "8090"
            }

            initial_delay_seconds = 25
            period_seconds        = 25
          }

          image_pull_policy = "Always"
        }
        host_aliases {
          ip = var.nginx_ip
          hostnames = [ var.hostname ]
        }
      }
    }
  }
}


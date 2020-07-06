resource "kubernetes_config_map" "oxtrust_cm" {
  metadata {
    name = "oxtrust-cm"
  }

  depends_on = [null_resource.waitfor-persistence]

  data = {
    DOMAIN                = var.hostname
    GLUU_CONFIG_ADAPTER   = "kubernetes"
    GLUU_LDAP_URL         = "opendj:1636"
    GLUU_MAX_RAM_FRACTION = "1"
    GLUU_OXAUTH_BACKEND   = "oxauth:8080"
    GLUU_SECRET_ADAPTER   = "kubernetes"
  }
}

resource "kubernetes_service" "oxtrust" {
  metadata {
    name = "oxtrust"

    labels = {
      app = "oxtrust"
    }
  }

  depends_on = [null_resource.waitfor-persistence, null_resource.waitfor-oxauth]

  spec {
    port {
      name = "oxtrust"
      port = 8080
    }

    selector = {
      app = "oxtrust"
    }
  }
}

resource "kubernetes_stateful_set" "oxtrust" {
  metadata {
    name = "oxtrust"

    labels = {
      APP_NAME = "oxtrust"

      app = "oxtrust"
    }
  }

  depends_on = [kubernetes_service.oxtrust, null_resource.waitfor-persistence]

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "oxtrust"
      }
    }

    template {
      metadata {
        labels = {
          APP_NAME = "oxtrust"

          app = "oxtrust"
        }
      }

      spec {
        automount_service_account_token = true

        volume {
          name = "vol-userman"

          persistent_volume_claim {
            claim_name = "eoepca-userman-pvc"
          }
        }

        container {
          name  = "oxtrust"
          image = "gluufederation/oxtrust:4.1.1_02"

          port {
            container_port = 8080
          }

          env_from {
            config_map_ref {
              name = "oxtrust-cm"
            }
          }

          volume_mount {
            name       = "vol-userman"
            mount_path = "/opt/gluu/jetty/identity/logs"
            sub_path   = "oxtrust/logs"
          }

          volume_mount {
            name       = "vol-userman"
            mount_path = "/opt/gluu/jetty/identity/lib/ext"
            sub_path   = "oxtrust/lib/ext"
          }

          volume_mount {
            name       = "vol-userman"
            mount_path = "/opt/gluu/jetty/identity/custom/static"
            sub_path   = "oxtrust/custom/static"
          }

          volume_mount {
            name       = "vol-userman"
            mount_path = "/opt/gluu/jetty/identity/custom/pages"
            sub_path   = "oxtrust/custom/pages"
          }

          image_pull_policy = "Always"
        }
        host_aliases {
          ip        = var.nginx_ip
          hostnames = [var.hostname]
        }
      }
    }

    service_name = "oxtrust"
  }
}


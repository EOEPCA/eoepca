resource "kubernetes_config_map" "oxauth_cm" {
  metadata {
    name = "oxauth-cm"
  }
  data = {
    DOMAIN                   = var.hostname,
    GLUU_CONFIG_ADAPTER      = "kubernetes",
    GLUU_LDAP_URL            = "opendj:1636",
    GLUU_MAX_RAM_FRACTION    = "1",
    GLUU_SECRET_ADAPTER      = "kubernetes",
    GLUU_SYNC_CASA_MANIFESTS = "false"
  }
}

resource "kubernetes_service" "oxauth" {
  metadata {
    name   = "oxauth"
    labels = { app = "oxauth" }
  }
  spec {
    port {
      name = "oxauth"
      port = 8080
    }
    selector = { app = "oxauth" }
  }
}

resource "kubernetes_deployment" "oxauth" {
  metadata {
    name   = "oxauth"
    labels = { app = "oxauth" }
  }
  spec {
    replicas = 1
    selector {
      match_labels = { app = "oxauth" }
    }
    template {
      metadata {
        labels = { app = "oxauth" }
      }
      spec {
        volume {
          name = "oxauth-logs"
          persistent_volume_claim {
            claim_name = "oxauth-logs-volume-claim"
          }
        }
        volume {
          name = "oxauth-lib-ext"
          persistent_volume_claim {
            claim_name = "oxauth-lib-ext-volume-claim"
          }
        }
        volume {
          name = "oxauth-custom-static"
          persistent_volume_claim {
            claim_name = "oxauth-custom-static-volume-claim"
          }
        }
        volume {
          name = "oxauth-custom-pages"
          persistent_volume_claim {
            claim_name = "oxauth-custom-pages-volume-claim"
          }
        }
        container {
          name  = "oxauth"
          image = "gluufederation/oxauth:4.1.1_03"
          port {
            container_port = 8080
          }
          env_from {
            config_map_ref {
              name = "oxauth-cm"
            }
          }
          volume_mount {
            name       = "oxauth-logs"
            mount_path = "/opt/gluu/jetty/oxauth/logs"
          }
          volume_mount {
            name       = "oxauth-lib-ext"
            mount_path = "/opt/gluu/jetty/oxauth/lib/ext"
          }
          volume_mount {
            name       = "oxauth-custom-static"
            mount_path = "/opt/gluu/jetty/oxauth/custom/static"
          }
          volume_mount {
            name       = "oxauth-custom-pages"
            mount_path = "/opt/gluu/jetty/oxauth/custom/pages"
          }
          image_pull_policy = "Always"
        }
        host_alias {
          ip        = var.nginx_ip
          hostnames = [ var.hostname ]
        }
      }
    }
  }
}


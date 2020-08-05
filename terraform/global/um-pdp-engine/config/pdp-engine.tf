resource "kubernetes_config_map" "pdp_engine_cm" {
  metadata {
    name = "um-pdp-engine-config"
  }
  data = {
    PDP_AUTH_SERVER_URL = "https://${var.hostname}"
    PDP_PREFIX          = "/"
    PDP_HOST            = "0.0.0.0"
    PDP_PORT            = "5567"
    PDP_CHECK_SSL_CERTS = "false"
    PDP_DEBUG_MODE      = "true"
  }
}

resource "kubernetes_ingress" "gluu_ingress_pdp_engine" {
  metadata {
    name = "gluu-ingress-pdp-engine"

    annotations = {
      "kubernetes.io/ingress.class"              = "nginx"
      "nginx.ingress.kubernetes.io/ssl-redirect" = "false"
    }
  }

  spec {
    rule {
      host = var.hostname

      http {
        path {
          path = "/pdp"

          backend {
            service_name = "pdp-engine"
            service_port = "5567"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "pdp-engine" {
  metadata {
    name   = "pdp-engine"
    labels = { app = "pdp-engine" }
  }

  spec {
    type = "NodePort"

    port {
      name        = "http-pdp"
      port        = 5567
      target_port = 5567
      node_port   = 31708
    }
    port {
      name        = "https-pdp"
      port        = 1025
      target_port = 443
    }
    selector = { app = "pdp-engine" }
  }
}

resource "kubernetes_deployment" "pdp-engine" {
  metadata {
    name   = "pdp-engine"
    labels = { app = "pdp-engine" }
  }

  spec {
    replicas = 1
    selector {
      match_labels = { app = "pdp-engine" }
    }
    template {
      metadata {
        labels = { app = "pdp-engine" }
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
          name  = "pdp-engine"
          image = "eoepca/um-pdp-engine:travis_26"

          port {
            container_port = 5567
            name           = "http-pdp"
          }
          port {
            container_port = 443
            name           = "https-pdp"
          }
          env_from {
            config_map_ref {
              name = "um-pdp-engine-config"
            }
          }
          volume_mount {
            name       = "vol-userman"
            mount_path = "/data/db/policy"
            sub_path   = "pep-engine/db/policy"
          }
          image_pull_policy = "Always"
        }
        container {
          name  = "mongo"
          image = "mongo"
          port {
            container_port = 27017
            name           = "http-rp"
          }

          env_from {
            config_map_ref {
              name = "um-pdp-engine-config"
            }
          }
          volume_mount {
            name       = "vol-userman"
            mount_path = "/data/db/policy"
            sub_path   = "pep-engine/db/policy"
          }
          image_pull_policy = "Always"
        }

        host_aliases {
          ip        = var.nginx_ip
          hostnames = [var.hostname]
        }
      }
    }
  }
}


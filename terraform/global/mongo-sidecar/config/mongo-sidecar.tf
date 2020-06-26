resource "kubernetes_config_map" "mongo_sidecar_cm" {
  metadata {
    name = "um-mongo-sidecar-config"
  }
  
  depends_on = [ null_resource.waitfor-login-service ]

  data = {
    PEP_AUTH_SERVER_URL          = "https://${var.hostname}"
    PEP_PROXY_ENDPOINT           = "/"
    PEP_SERVICE_HOST             = "0.0.0.0"
    PEP_SERVICE_PORT             = "5566"
    PEP_S_MARGIN_RPT_VALID       = "5"
    PEP_CHECK_SSL_CERTS          = "false"
    PEP_USE_THREADS              = "true"
    PEP_DEBUG_MODE               = "true"
    PEP_RESOURCE_SERVER_ENDPOINT = "http://ades/"

  }
}


resource "kubernetes_ingress" "gluu_ingress_mongo-sidecar" {
  metadata {
    name = "gluu-ingress-mongo-sidecar"

    annotations = {
      "kubernetes.io/ingress.class" = "nginx"
      "nginx.ingress.kubernetes.io/ssl-redirect" = "false"
    }
  }

  spec {
    rule {
      host =  var.hostname 

      http {
        path {
          path = "/static"

          backend {
            service_name = "mongo-sidecar"
            service_port = "5566"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "mongo-sidecar" {
  metadata {
    name   = "mongo-sidecar"
    labels = { app = "mongo-sidecar" }
  }

  spec {
    type = "NodePort"

    port {
      name = "http-ms"
      port = 5566
      target_port = 5566
    }
    port {
      name = "https-ms"
      port = 1029
      target_port = 443
    }
    selector = { app = "mongo-sidecar" }
  }
}

resource "kubernetes_deployment" "mongo-sidecar" {
  metadata {
    name   = "mongo-sidecar"
    labels = { app = "mongo-sidecar" }
  }
  
  spec {
    replicas = 1
    selector {
      match_labels = { app = "mongo-sidecar" }
    }
    template {
      metadata {
        labels = { app = "mongo-sidecar" }
      }
      spec {
  
        automount_service_account_token = true
  
        volume {
          name = "mongo-sidecar-logs"
          persistent_volume_claim {
            claim_name = "mongo-sidecar-logs-volume-claim"
          }
        }
        volume {
          name = "mongo-sidecar-lib-ext"
          persistent_volume_claim {
            claim_name = "mongo-sidecar-lib-ext-volume-claim"
          }
        }
        volume {
          name = "mongo-sidecar-custom-static"
          persistent_volume_claim {
            claim_name = "mongo-sidecar-custom-static-volume-claim"
          }
        }
        volume {
          name = "mongo-sidecar-custom-pages"
          persistent_volume_claim {
            claim_name = "mongo-sidecar-custom-pages-volume-claim"
          }
        }
        container {
          name  = "mongo-sidecar"
          image = "mongo"
          port {
            container_port = 5566
            name = "http-ms"
          }
          port {
            container_port = 443
            name = "https-ms"
          }
          env_from {
            config_map_ref {
              name = "um-mongo-sidecar-config"
            }
          }
          volume_mount {
            name       = "mongo-sidecar-logs"
            mount_path = "/opt/gluu/jetty/mongo-sidecar/logs"
          }
          volume_mount {
            name       = "mongo-sidecar-lib-ext"
            mount_path = "/opt/gluu/jetty/mongo-sidecar/lib/ext"
          }
          volume_mount {
            name       = "mongo-sidecar-custom-static"
            mount_path = "/opt/gluu/jetty/mongo-sidecar/custom/static"
          }
          volume_mount {
            name       = "mongo-sidecar-custom-pages"
            mount_path = "/opt/gluu/jetty/mongo-sidecar/custom/pages"
          }
          image_pull_policy = "Always"
        }
        host_aliases {
          ip        = var.nginx_ip
          hostnames = [ var.hostname ]
        }
      }
    }
  }
}



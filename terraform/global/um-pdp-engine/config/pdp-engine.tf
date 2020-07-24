resource "kubernetes_config_map" "pdp_engine_cm" {
  metadata {
    name = "um-pdp-engine-config"
  }

  depends_on = [ null_resource.waitfor-login-service ]

  data = {
    PEP_REALM                    = "eoepca"
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

resource "kubernetes_ingress" "gluu_ingress_pdp_engine" {
  metadata {
    name = "gluu-ingress-pdp-engine"

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
          path = "/pdp"

          backend {
            service_name = "pdp-engine"
            service_port = "5566"
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
      name = "http-pdp"
      port = 5566
      target_port = 5566
      node_port = 31707
    }
    port {
      name = "https-pdp"
      port = 1025
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
          name = "pdp-engine-logs"
          persistent_volume_claim {
            claim_name = "pdp-engine-logs-volume-claim"
          }
        }
        volume {
          name = "pdp-engine-lib-ext"
          persistent_volume_claim {
            claim_name = "pdp-engine-lib-ext-volume-claim"
          }
        }
        volume {
          name = "pdp-engine-custom-static"
          persistent_volume_claim {
            claim_name = "pdp-engine-custom-static-volume-claim"
          }
        }
        volume {
          name = "pdp-engine-custom-pages"
          persistent_volume_claim {
            claim_name = "pdp-engine-custom-pages-volume-claim"
          }
        }
        volume {
          name = "mongo-persistent-storage"
          persistent_volume_claim {
            claim_name = "mongo-persistent-storage-volume-claim"
          }
        }
        container {
          name  = "pdp-engine"
          image = "eoepca/um-pdp-engine:travis_11"

          port {
            container_port = 5566
            name = "http-pdp"
          }
          port {
            container_port = 443
            name = "https-pdp"
          }
          env_from {
            config_map_ref {
              name = "um-pdp-engine-config"
            }
          }
          volume_mount {
            name       = "pdp-engine-logs"
            mount_path = "/opt/gluu/jetty/pdp-engine/logs"
          }
          volume_mount {
            name       = "pdp-engine-lib-ext"
            mount_path = "/opt/gluu/jetty/pdp-engine/lib/ext"
          }
          volume_mount {
            name       = "pdp-engine-custom-static"
            mount_path = "/opt/gluu/jetty/pdp-engine/custom/static"
          }
          volume_mount {
            name       = "pdp-engine-custom-pages"
            mount_path = "/opt/gluu/jetty/pdp-engine/custom/pages"
          }
          volume_mount {
            name       = "mongo-persistent-storage"
            mount_path = "/data/db/policy"
          }
          image_pull_policy = "Always"
        }
        container {
          name  = "mongo"
          image = "mongo"
          port {
            container_port = 27017
            name = "http-rp"
          }
        
          env_from {
            config_map_ref {
              name = "um-pdp-engine-config"
            }
          }
          volume_mount {
            name       = "mongo-persistent-storage"
            mount_path = "/data/db/policy"
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


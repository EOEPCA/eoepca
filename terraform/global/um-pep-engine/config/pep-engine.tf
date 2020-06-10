resource "kubernetes_config_map" "pep_engine_cm" {
  metadata {
    name = "um-pep-engine-config"
  }

  data = {
    PEP_REALM                    = "eoepca"
    PEP_AUTH_SERVER_URL          = var.hostname
    PEP_PROXY_ENDPOINT           = "/pep"
    PEP_SERVICE_HOST             = "0.0.0.0"
    PEP_SERVICE_PORT             = "5566"
    PEP_S_MARGIN_RPT_VALID       = "5"
    PEP_CHECK_SSL_CERTS          = "false"
    PEP_USE_THREADS              = "true"
    PEP_DEBUG_MODE               = "true"
    PEP_RESOURCE_SERVER_ENDPOINT = "http://localhost:9000"
  }
}

resource "kubernetes_service" "pep-engine" {
  metadata {
    name   = "pep-engine"
    labels = { app = "pep-engine" }
  }

  depends_on = [ null_resource.waitfor-persistence, kubernetes_persistent_volume.pep_engine_logs,
                kubernetes_persistent_volume.pep_engine_lib_ext, kubernetes_persistent_volume.pep_engine_custom_static,
                kubernetes_persistent_volume.pep_engine_custom_pages ]
  
  spec {
    port {
      name = "http-pep"
      port = 80
    }
    port {
      name = "https-pep"
      port = 443
    }
    selector = { app = "pep-engine" }
  }
}

resource "kubernetes_deployment" "pep-engine" {
  metadata {
    name   = "pep-engine"
    labels = { app = "pep-engine" }
  }

  depends_on = [ null_resource.waitfor-persistence, kubernetes_persistent_volume.pep_engine_logs,
                kubernetes_persistent_volume.pep_engine_lib_ext, kubernetes_persistent_volume.pep_engine_custom_static,
                kubernetes_persistent_volume.pep_engine_custom_pages ]
  
  spec {
    replicas = 1
    selector {
      match_labels = { app = "pep-engine" }
    }
    template {
      metadata {
        labels = { app = "pep-engine" }
      }
      spec {
  
        automount_service_account_token = true
  
        volume {
          name = "pep-engine-logs"
          persistent_volume_claim {
            claim_name = "pep-engine-logs-volume-claim"
          }
        }
        volume {
          name = "pep-engine-lib-ext"
          persistent_volume_claim {
            claim_name = "pep-engine-lib-ext-volume-claim"
          }
        }
        volume {
          name = "pep-engine-custom-static"
          persistent_volume_claim {
            claim_name = "pep-engine-custom-static-volume-claim"
          }
        }
        volume {
          name = "pep-engine-custom-pages"
          persistent_volume_claim {
            claim_name = "pep-engine-custom-pages-volume-claim"
          }
        }
        container {
          name  = "pep-engine"
          image = "eoepca/um-pep-engine:latest"
          port {
            container_port = 80
            name = "http-pep"
          }
          port {
            container_port = 443
            name = "https-pep"
          }
          env_from {
            config_map_ref {
              name = "um-pep-engine-config"
            }
          }
          volume_mount {
            name       = "pep-engine-logs"
            mount_path = "/opt/gluu/jetty/pep-engine/logs"
          }
          volume_mount {
            name       = "pep-engine-lib-ext"
            mount_path = "/opt/gluu/jetty/pep-engine/lib/ext"
          }
          volume_mount {
            name       = "pep-engine-custom-static"
            mount_path = "/opt/gluu/jetty/pep-engine/custom/static"
          }
          volume_mount {
            name       = "pep-engine-custom-pages"
            mount_path = "/opt/gluu/jetty/pep-engine/custom/pages"
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


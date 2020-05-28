resource "kubernetes_config_map" "oxtrust_cm" {
  metadata {
    name = "oxtrust-cm"
  }

  depends_on = [ null_resource.waitfor-persistence ]

  data = {
    DOMAIN = var.hostname
    GLUU_CONFIG_ADAPTER = "kubernetes"
    GLUU_LDAP_URL = "opendj:1636"
    GLUU_MAX_RAM_FRACTION = "1"
    GLUU_OXAUTH_BACKEND = "oxauth:8080"
    GLUU_SECRET_ADAPTER = "kubernetes"
  }
}

resource "kubernetes_service" "oxtrust" {
  metadata {
    name = "oxtrust"

    labels = {
      app = "oxtrust"
    }
  }

  depends_on = [ null_resource.waitfor-persistence, kubernetes_persistent_volume.oxtrust_logs,
                kubernetes_persistent_volume.oxtrust_lib_ext, kubernetes_persistent_volume.oxtrust_custom_static,
                kubernetes_persistent_volume.oxtrust_custom_pages ]

  spec {
    port {
      name = "oxtrust"
      port = 8080
    }

    selector = {
      app = "oxtrust"
    }
  }
  provisioner "local-exec" {
    command = <<EOT
      until [ `kubectl logs service/oxtrust | grep "Server:main: Started" | wc -l` -ge 1 ]; do echo "Waiting for service/oxtrust" && sleep 30; done
    EOT
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

   depends_on = [ kubernetes_service.oxtrust, null_resource.waitfor-persistence, kubernetes_persistent_volume.oxtrust_logs,
                kubernetes_persistent_volume.oxtrust_lib_ext, kubernetes_persistent_volume.oxtrust_custom_static,
                kubernetes_persistent_volume.oxtrust_custom_pages ]

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
          name = "oxtrust-logs"

          persistent_volume_claim {
            claim_name = "oxtrust-logs-volume-claim"
          }
        }

        volume {
          name = "oxtrust-lib-ext"

          persistent_volume_claim {
            claim_name = "oxtrust-lib-ext-volume-claim"
          }
        }

        volume {
          name = "oxtrust-custom-static"

          persistent_volume_claim {
            claim_name = "oxtrust-custom-static-volume-claim"
          }
        }

        volume {
          name = "oxtrust-custom-pages"

          persistent_volume_claim {
            claim_name = "oxtrust-custom-pages-volume-claim"
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
            name       = "oxtrust-logs"
            mount_path = "/opt/gluu/jetty/identity/logs"
          }

          volume_mount {
            name       = "oxtrust-lib-ext"
            mount_path = "/opt/gluu/jetty/identity/lib/ext"
          }

          volume_mount {
            name       = "oxtrust-custom-static"
            mount_path = "/opt/gluu/jetty/identity/custom/static"
          }

          volume_mount {
            name       = "oxtrust-custom-pages"
            mount_path = "/opt/gluu/jetty/identity/custom/pages"
          }

          image_pull_policy = "Always"
        }
        host_aliases {
          ip = var.nginx_ip
          hostnames = [ var.hostname ]
        }
      }
    }

    service_name = "oxtrust"
  }
}


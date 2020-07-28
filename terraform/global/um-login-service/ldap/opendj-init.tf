resource "kubernetes_config_map" "opendj_init_cm" {
  metadata {
    name = "opendj-init-cm"
  }

  depends_on = [ null_resource.waitfor-config-init ]

  data = {
    GLUU_CONFIG_ADAPTER = "kubernetes"
    GLUU_LDAP_ADVERTISE_ADRR = "opendj"
    GLUU_LDAP_AUTO_REPLICATE = "false"
    GLUU_SECRET_ADAPTER = "kubernetes"
  }
}

resource "kubernetes_service" "opendj" {
  metadata {
    name = "opendj"

    labels = {
      app = "opendj"
    }
  }

  depends_on = [ null_resource.waitfor-config-init ]

  spec {
    
    port {
      name        = "ldaps"
      protocol    = "TCP"
      port        = 1636
      target_port = "1636"
    }

    port {
      name        = "ldap"
      protocol    = "TCP"
      port        = 1389
      target_port = "1389"
    }

    port {
      name        = "replication"
      protocol    = "TCP"
      port        = 8989
      target_port = "8989"
    }

    port {
      name        = "admin"
      protocol    = "TCP"
      port        = 4444
      target_port = "4444"
    }

    selector = {
      app = "opendj"
    }

    # cluster_ip = "None" Defaults to ClusterIP
  }
}

resource "kubernetes_stateful_set" "opendj_init" {
  metadata {
    name = "opendj-init"
  }

  depends_on = [ null_resource.waitfor-config-init ]

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "opendj"
      }
    }

    template {
      metadata {
        labels = {
          app = "opendj"
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
          name  = "opendj"
          image = "gluufederation/wrends:4.1.1_01"

          port {
            name           = "ldaps"
            container_port = 1636
          }

          port {
            name           = "ldap"
            container_port = 1389
          }

          port {
            name           = "replication"
            container_port = 8989
          }

          port {
            name           = "admin"
            container_port = 4444
          }

          env_from {
            config_map_ref {
              name = "opendj-init-cm"
            }
          }

          volume_mount {
            name       = "vol-userman"
            mount_path = "/opt/opendj/config"
            sub_path   = "opendj/config"
          }

          volume_mount {
            name       = "vol-userman"
            mount_path = "/opt/opendj/ldif"
            sub_path   = "opendj/ldif"
          }

          volume_mount {
            name       = "vol-userman"
            mount_path = "/opt/opendj/logs"
            sub_path   = "opendj/logs"
          }

          volume_mount {
            name       = "vol-userman"
            mount_path = "/opt/opendj/db"
            sub_path   = "opendj/db"
          }

          volume_mount {
            name       = "vol-userman"
            mount_path = "/flag"
            sub_path   = "opendj/flag"
          }

          liveness_probe {
            tcp_socket {
              port = "1636"
            }

            initial_delay_seconds = 30
            period_seconds        = 30
          }

          readiness_probe {
            tcp_socket {
              port = "1636"
            }

            initial_delay_seconds = 25
            period_seconds        = 25
          }

          image_pull_policy = "Always"
        }
      }
    }

    service_name = "opendj"
  }
}


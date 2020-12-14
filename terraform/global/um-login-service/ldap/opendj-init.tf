resource "kubernetes_config_map" "opendj_init_cm" {
  metadata {
    name = "opendj-init-cm"
  }

  data = {
    GLUU_CONFIG_ADAPTER      = "kubernetes"
    GLUU_LDAP_ADVERTISE_ADRR = "opendj"
    GLUU_LDAP_AUTO_REPLICATE = "false"
    GLUU_SECRET_ADAPTER      = "kubernetes"
  }
}

resource "kubernetes_service" "opendj" {
  metadata {
    name = "opendj"

    labels = {
      app = "opendj"
    }
  }

  depends_on = [null_resource.waitfor-module-depends]

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

  depends_on = [kubernetes_service.opendj]

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

  provisioner "local-exec" {
    command = <<-EOT
      until kubectl get pods 2>/dev/null | grep "opendj" | grep "Running" >/dev/null 2>&1
      do
        echo "Waiting for load custom attributes into opendj-inint0"
        sleep $(( 5 ))
      done
      kubectl cp $PWD/../global/um-login-service/ldap/77-customAttributes.ldif opendj-init-0:opt/opendj/template/config/schema/77-customAttributes.ldif
      EOT
  }

  provisioner "local-exec" {
    command = <<-EOT
      interval=$(( 5 ))
      msgInterval=$(( 30 ))
      step=$(( msgInterval / interval ))
      count=$(( 0 ))
      until kubectl logs opendj-init-0 2>/dev/null | grep "The Directory Server has started successfully" >/dev/null 2>&1
      do
        test $(( count % step )) -eq 0 && echo "Waiting for opendj-init0"
        sleep $interval
        count=$(( count + interval ))
      done
      EOT
  }
}

resource "kubernetes_config_map" "oxauth_cm" {
  metadata {
    name = "oxauth-cm"
  }

  data = {
    DOMAIN                   = var.hostname
    GLUU_CONFIG_ADAPTER      = "kubernetes"
    GLUU_LDAP_URL            = "opendj:1636"
    GLUU_MAX_RAM_FRACTION    = "1"
    GLUU_SECRET_ADAPTER      = "kubernetes"
    GLUU_SYNC_CASA_MANIFESTS = "false"
  }
}

resource "kubernetes_service" "oxauth" {
  metadata {
    name   = "oxauth"
    labels = { app = "oxauth" }
  }

  depends_on = [kubernetes_deployment.oxauth]

  spec {
    port {
      name = "oxauth"
      port = 8080
    }
    selector = { app = "oxauth" }
  }

  provisioner "local-exec" {
    command = <<-EOT
      interval=$(( 5 ))
      msgInterval=$(( 30 ))
      step=$(( msgInterval / interval ))
      count=$(( 0 ))
      until kubectl logs service/oxauth 2>/dev/null | grep "Server:main: Started" >/dev/null 2>&1
      do
        kubectl logs service/oxauth
        test $(( count % step )) -eq 0 && echo "Waiting for service/oxauth"
        sleep $interval
        count=$(( count + interval ))
      done
      EOT
  }
}

resource "kubernetes_deployment" "oxauth" {
  metadata {
    name   = "oxauth"
    labels = { app = "oxauth" }
  }

  depends_on = [null_resource.waitfor-module-depends]

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

        automount_service_account_token = true

        volume {
          name = "vol-userman"

          persistent_volume_claim {
            claim_name = "eoepca-userman-pvc"
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
            name       = "vol-userman"
            mount_path = "/opt/gluu/jetty/oxauth/logs"
            sub_path   = "oxauth/logs"
          }
          volume_mount {
            name       = "vol-userman"
            mount_path = "/opt/gluu/jetty/oxauth/lib/ext"
            sub_path   = "oxauth/lib/ext"
          }
          volume_mount {
            name       = "vol-userman"
            mount_path = "/opt/gluu/jetty/oxauth/custom/static"
            sub_path   = "oxauth/custom/static"
          }
          volume_mount {
            name       = "vol-userman"
            mount_path = "/opt/gluu/jetty/oxauth/custom/pages"
            sub_path   = "oxauth/custom/pages"
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


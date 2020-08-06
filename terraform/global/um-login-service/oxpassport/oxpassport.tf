resource "kubernetes_config_map" "oxpassport_cm" {
  metadata {
    name = "oxpassport-cm"
  }

  data = {
    DOMAIN                = var.hostname
    GLUU_CONFIG_ADAPTER   = "kubernetes"
    GLUU_LDAP_URL         = "opendj:1636"
    GLUU_MAX_RAM_FRACTION = "1"
    GLUU_SECRET_ADAPTER   = "kubernetes"
  }
}

resource "kubernetes_service" "oxpassport" {
  metadata {
    name = "oxpassport"

    labels = {
      app = "oxpassport"
    }
  }

  depends_on = [kubernetes_deployment.oxpassport]

  spec {
    port {
      name = "oxpassport"
      port = 8090
    }

    selector = {
      app = "oxpassport"
    }
  }

  provisioner "local-exec" {
    command = <<-EOT
      interval=$(( 5 ))
      msgInterval=$(( 30 ))
      step=$(( msgInterval / interval ))
      count=$(( 0 ))
      until kubectl logs service/oxpassport 2>/dev/null | grep "Server listening on" >/dev/null 2>&1
      do
        test $(( count % step )) -eq 0 && echo "Waiting for service/oxpassport"
        sleep $interval
        count=$(( count + interval ))
      done
      EOT
  }
}

resource "kubernetes_deployment" "oxpassport" {
  metadata {
    name = "oxpassport"

    labels = {
      app = "oxpassport"
    }
  }

  depends_on = [null_resource.waitfor-module-depends]

  timeouts {
    create = "10m"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "oxpassport"
      }
    }

    template {
      metadata {
        labels = {
          app = "oxpassport"
        }
      }

      spec {
        automount_service_account_token = true

        container {

          name  = "oxpassport"
          image = "eoepca/um-login-passport:v0.1.1"

          port {
            container_port = 8090
          }

          env_from {
            config_map_ref {
              name = "oxpassport-cm"
            }
          }

          liveness_probe {
            http_get {
              path = "/passport/token"
              port = "8090"
            }

            initial_delay_seconds = 300
            period_seconds        = 30
          }

          readiness_probe {
            http_get {
              path = "/passport/token"
              port = "8090"
            }

            initial_delay_seconds = 250
            period_seconds        = 25
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

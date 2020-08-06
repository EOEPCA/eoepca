resource "kubernetes_config_map" "user_profile_cm" {
  metadata {
    name = "um-user-profile-config"
  }

  data = {
    UP_SSO_URL                  = var.hostname
    UP_TITLE                    = "EOEPCA User Profile"
    UP_SCOPES                   = "openid email user_name"
    UP_REDIRECT_URI             = "http://${var.hostname}/web_ui/oauth/callback"
    UP_POST_LOGOUT_REDIRECT_URI = "http://${var.hostname}/web_ui"
    UP_BASE_URI                 = "/web_ui"
    UP_OAUTH_CALLBACK_PATH      = "/oauth/callback"
    UP_LOGOUT_ENDPOINT          = "/logout"
    UP_SERVICE_HOST             = "0.0.0.0"
    UP_SERVICE_PORT             = "5566"
    UP_PROTECTED_ATTRIBUTES     = "userName active emails displayName value primary"
    UP_BLACKLIST_ATTRIBUTES     = "schemas id meta $ref"
    UP_SEPARATOR_UI_ATTRIBUTES  = "->"
    UP_COLOR_WEB_BACKGROUND     = "#D7EDEC"
    UP_COLOR_WEB_HEADER         = "#FFFFFF"
    UP_LOGO_ALT_NAME            = "EOEPCA Logo"
    UP_LOGO_IMAGE_PATH          = "/static/img/logo.png"
    UP_COLOR_HEADER_TABLE       = "#38A79F"
    UP_COLOR_TEXT_HEADER_TABLE  = "white"
    UP_COLOR_BUTTON_MODIFY      = "#38A79F"
    UP_USE_THREADS              = "true"
    UP_DEBUG_MODE               = "true"
  }
}

resource "kubernetes_ingress" "gluu_ingress_user_profile_static" {
  metadata {
    name = "gluu-ingress-user-profile-static"

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
          path = "/static"

          backend {
            service_name = "user-profile"
            service_port = "5566"
          }
        }
      }
    }
  }
}

resource "kubernetes_ingress" "gluu_ingress_user_profile" {
  metadata {
    name = "gluu-ingress-user-profile"

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
          path = "/web_ui"

          backend {
            service_name = "user-profile"
            service_port = "5566"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "user-profile" {
  metadata {
    name   = "user-profile"
    labels = { app = "user-profile" }
  }
  depends_on = [kubernetes_deployment.user-profile]

  spec {
    type = "NodePort"

    port {
      name        = "http-up"
      port        = 5566
      target_port = 5566
    }
    port {
      name        = "https-up"
      port        = 1028
      target_port = 443
    }
    selector = { app = "user-profile" }
  }

  provisioner "local-exec" {
    command = <<-EOT
      interval=$(( 5 ))
      msgInterval=$(( 30 ))
      step=$(( msgInterval / interval ))
      count=$(( 0 ))
      until kubectl logs service/user-profile 2>/dev/null | grep "Running on http://0.0.0.0" >/dev/null 2>&1
      do
        test $(( count % step )) -eq 0 && echo "Waiting for service/user-profile"
        sleep $interval
        count=$(( count + interval ))
      done
      EOT
  }
}

resource "kubernetes_deployment" "user-profile" {

  metadata {
    name   = "user-profile"
    labels = { app = "user-profile" }
  }
  depends_on = [null_resource.waitfor-module-depends]

  spec {
    replicas = 1
    selector {
      match_labels = { app = "user-profile" }
    }
    template {
      metadata {
        labels = { app = "user-profile" }
      }
      spec {

        automount_service_account_token = true

        volume {
          name = "um-user-profile-config"

          config_map {
            name = "um-user-profile-config"
          }
        }
        volume {
          name = "vol-userman"

          persistent_volume_claim {
            claim_name = "eoepca-userman-pvc"
          }
        }
        container {
          name  = "user-profile"
          image = "eoepca/um-user-profile:v0.1.1"
          port {
            container_port = 5566
            name           = "http-up"
          }
          port {
            container_port = 443
            name           = "https-up"
          }
          env_from {
            config_map_ref {
              name = "um-user-profile-config"
            }
          }
          volume_mount {
            name              = "um-user-profile-config"
            mount_path        = "/opt/user-profile/db/um-user-profile-config"
            sub_path          = "um-user-profile-config"
            mount_propagation = "HostToContainer"
          }
          volume_mount {
            name       = "vol-userman"
            mount_path = "/opt/gluu/jetty/user-profile/logs"
            sub_path   = "user-profile/logs"
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

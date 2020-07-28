resource "kubernetes_ingress" "gluu_ingress_base" {
  metadata {
    name = "gluu-ingress-base"

    annotations = {
      "kubernetes.io/ingress.class" = "nginx"

      "nginx.ingress.kubernetes.io/affinity" = "cookie"

      "nginx.ingress.kubernetes.io/app-root" = "/identity"

      "nginx.ingress.kubernetes.io/session-cookie-hash" = "sha1"

      "nginx.ingress.kubernetes.io/session-cookie-name" = "route"
    }
  }

  spec {
    tls {
      hosts       = [ var.hostname ]
      secret_name = "tls-certificate"
    }

    rule {
      host = var.hostname

      http {
        path {
          path = "/"

          backend {
            service_name = "oxtrust"
            service_port = "8080"
          }
        }
      }
    }
  }
  depends_on = [ null_resource.waitfor-tls-secrets, null_resource.waitfor-persistence ]
}

resource "kubernetes_ingress" "gluu_ingress_openid_configuration" {
  metadata {
    name = "gluu-ingress-openid-configuration"

    annotations = {
      "kubernetes.io/ingress.class" = "nginx"

      "nginx.ingress.kubernetes.io/configuration-snippet" = "rewrite /.well-known/openid-configuration /oxauth/.well-known/openid-configuration$1 break;"

      "nginx.ingress.kubernetes.io/proxy-read-timeout" = "300"

      "nginx.ingress.kubernetes.io/rewrite-target" = "/oxauth/.well-known/openid-configuration"

      "nginx.ingress.kubernetes.io/ssl-redirect" = "false"
    }
  }

  spec {
    tls {
      hosts       = [ var.hostname ]
      secret_name = "tls-certificate"
    }

    rule {
      host =  var.hostname 

      http {
        path {
          path = "/.well-known/openid-configuration"

          backend {
            service_name = "oxauth"
            service_port = "8080"
          }
        }
      }
    }
  }
  depends_on = [ null_resource.waitfor-tls-secrets, null_resource.waitfor-persistence ]
}

resource "kubernetes_ingress" "gluu_ingress_uma_2__configuration" {
  metadata {
    name = "gluu-ingress-uma2-configuration"

    annotations = {
      "kubernetes.io/ingress.class" = "nginx"

      "nginx.ingress.kubernetes.io/configuration-snippet" = "rewrite /.well-known/uma2-configuration /oxauth/restv1/uma2-configuration$1 break;"

      "nginx.ingress.kubernetes.io/proxy-read-timeout" = "300"

      "nginx.ingress.kubernetes.io/rewrite-target" = "/oxauth/restv1/uma2-configuration"

      "nginx.ingress.kubernetes.io/ssl-redirect" = "false"
    }
  }

  spec {
    tls {
      hosts       = [ var.hostname ]
      secret_name = "tls-certificate"
    }

    rule {
      host =  var.hostname 

      http {
        path {
          path = "/.well-known/uma2-configuration"

          backend {
            service_name = "oxauth"
            service_port = "8080"
          }
        }
      }
    }
  }
  depends_on = [ null_resource.waitfor-tls-secrets, null_resource.waitfor-persistence ]
}

resource "kubernetes_ingress" "gluu_ingress_webfinger" {
  metadata {
    name = "gluu-ingress-webfinger"

    annotations = {
      "kubernetes.io/ingress.class" = "nginx"

      "nginx.ingress.kubernetes.io/configuration-snippet" = "rewrite /.well-known/webfinger /oxauth/.well-known/webfinger$1 break;"

      "nginx.ingress.kubernetes.io/proxy-read-timeout" = "300"

      "nginx.ingress.kubernetes.io/rewrite-target" = "/oxauth/.well-known/webfinger"

      "nginx.ingress.kubernetes.io/ssl-redirect" = "false"
    }
  }

  spec {
    tls {
      hosts       = [ var.hostname ]
      secret_name = "tls-certificate"
    }

    rule {
      host =  var.hostname 

      http {
        path {
          path = "/.well-known/webfinger"

          backend {
            service_name = "oxauth"
            service_port = "8080"
          }
        }
      }
    }
  }
  depends_on = [ null_resource.waitfor-tls-secrets, null_resource.waitfor-persistence ]
}

resource "kubernetes_ingress" "gluu_ingress_simple_web_discovery" {
  metadata {
    name = "gluu-ingress-simple-web-discovery"

    annotations = {
      "kubernetes.io/ingress.class" = "nginx"

      "nginx.ingress.kubernetes.io/configuration-snippet" = "rewrite /.well-known/simple-web-discovery /oxauth/.well-known/simple-web-discovery$1 break;"

      "nginx.ingress.kubernetes.io/proxy-read-timeout" = "300"

      "nginx.ingress.kubernetes.io/rewrite-target" = "/oxauth/.well-known/simple-web-discovery"

      "nginx.ingress.kubernetes.io/ssl-redirect" = "false"
    }
  }

  spec {
    tls {
      hosts       = [ var.hostname ]
      secret_name = "tls-certificate"
    }

    rule {
      host =  var.hostname 

      http {
        path {
          path = "/.well-known/simple-web-discovery"

          backend {
            service_name = "oxauth"
            service_port = "8080"
          }
        }
      }
    }
  }
  depends_on = [ null_resource.waitfor-tls-secrets, null_resource.waitfor-persistence ]
}

resource "kubernetes_ingress" "gluu_ingress_scim_configuration" {
  metadata {
    name = "gluu-ingress-scim-configuration"

    annotations = {
      "kubernetes.io/ingress.class" = "nginx"

      "nginx.ingress.kubernetes.io/configuration-snippet" = "rewrite /.well-known/scim-configuration /identity/restv1/scim-configuration$1 break;"

      "nginx.ingress.kubernetes.io/proxy-read-timeout" = "300"

      "nginx.ingress.kubernetes.io/rewrite-target" = "/identity/restv1/scim-configuration"

      "nginx.ingress.kubernetes.io/ssl-redirect" = "false"
    }
  }

  spec {
    tls {
      hosts       = [ var.hostname ]
      secret_name = "tls-certificate"
    }

    rule {
      host =  var.hostname 

      http {
        path {
          path = "/.well-known/scim-configuration"

          backend {
            service_name = "oxtrust"
            service_port = "8080"
          }
        }
      }
    }
  }
  depends_on = [ null_resource.waitfor-tls-secrets, null_resource.waitfor-persistence ]
}

resource "kubernetes_ingress" "gluu_ingress_fido_u_2_f_configuration" {
  metadata {
    name = "gluu-ingress-fido-u2f-configuration"

    annotations = {
      "kubernetes.io/ingress.class" = "nginx"

      "nginx.ingress.kubernetes.io/configuration-snippet" = "rewrite /.well-known/fido-u2f-configuration /oxauth/restv1/fido-u2f-configuration$1 break;"

      "nginx.ingress.kubernetes.io/proxy-read-timeout" = "300"

      "nginx.ingress.kubernetes.io/rewrite-target" = "/oxauth/restv1/fido-u2f-configuration"

      "nginx.ingress.kubernetes.io/ssl-redirect" = "false"
    }
  }

  spec {
    tls {
      hosts       = [ var.hostname ]
      secret_name = "tls-certificate"
    }

    rule {
      host =  var.hostname 

      http {
        path {
          path = "/.well-known/fido-u2f-configuration"

          backend {
            service_name = "oxauth"
            service_port = "8080"
          }
        }
      }
    }
  }
  depends_on = [ null_resource.waitfor-tls-secrets, null_resource.waitfor-persistence ]
}

resource "kubernetes_ingress" "gluu_ingress" {
  metadata {
    name = "gluu-ingress"

    annotations = {
      "kubernetes.io/ingress.class" = "nginx"

      "nginx.ingress.kubernetes.io/proxy-next-upstream" = "error timeout invalid_header http_500 http_502 http_503 http_504"

      "nginx.org/ssl-services" = "oxauth"
    }
  }

  spec {
    tls {
      hosts       = [ var.hostname ]
      secret_name = "tls-certificate"
    }

    rule {
      host =  var.hostname 

      http {
        path {
          path = "/oxauth"

          backend {
            service_name = "oxauth"
            service_port = "8080"
          }
        }
      }
    }
  }
  depends_on = [ null_resource.waitfor-tls-secrets, null_resource.waitfor-persistence ]
}

resource "kubernetes_ingress" "gluu_ingress_stateful" {
  metadata {
    name = "gluu-ingress-stateful"

    annotations = {
      "kubernetes.io/ingress.class" = "nginx"

      "nginx.ingress.kubernetes.io/affinity" = "cookie"

      "nginx.ingress.kubernetes.io/app-root" = "/identity"

      "nginx.ingress.kubernetes.io/proxy-next-upstream" = "error timeout invalid_header http_500 http_502 http_503 http_504"

      "nginx.ingress.kubernetes.io/session-cookie-hash" = "sha1"

      "nginx.ingress.kubernetes.io/session-cookie-name" = "route"

      "nginx.org/ssl-services" = "oxtrust"
    }
  }

  spec {
    tls {
      hosts       = [var.hostname]
      secret_name = "tls-certificate"
    }

    rule {
      host = var.hostname

      http {
        path {
          path = "/identity"

          backend {
            service_name = "oxtrust"
            service_port = "8080"
          }
        }

        path {
          path = "/idp"

          backend {
            service_name = "oxshibboleth"
            service_port = "8080"
          }
        }

        path {
          path = "/passport"

          backend {
            service_name = "oxpassport"
            service_port = "8090"
          }
        }
      }
    }
  }
  depends_on = [ null_resource.waitfor-tls-secrets, null_resource.waitfor-persistence ]
}


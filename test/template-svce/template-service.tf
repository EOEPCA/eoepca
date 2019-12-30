resource "kubernetes_service" "template-service" {
  metadata {
    name = "template-service"
	namespace = "eo-services"
  }
  spec {
    type = "NodePort"
	
	selector = {
      app = "template-service"
	  tier = "service"
    }
    
    port {
      port        = 8080
      target_port = 7000
	  name = "http"
	  protocol = "TCP"
    }
  }
  timeouts {
    create = "3m"
  }
}

resource "kubernetes_deployment" "template-service-deployment" {
  metadata {
    name = "template-service-deployment"
    namespace = "eo-services"
  }

  spec {
    selector {
      match_labels = {
        app = "template-service"
	tier = "service"
      }
    }
	
    replicas = 1

    template {
      metadata {
        labels = {
          app = "template-service"
          tier = "service"
        }
      }

      spec {
        service_account_name = "bob-the-builder"
		
        container {
          image = "eoepcaci/template-service:latest"
          name  = "template-service"
          port {
            container_port = 7000
          }
		  
          env {
            name = "DB_USERNAME" # container specific environment variable name
            value_from {
	      secret_key_ref {
                name = "db-user-pass" # K8S secret name
	        key = "username" # key within the secret
	      }
            }
          }
          env {
            name = "DB_PASSWORD"
            value_from {
	      secret_key_ref {
	        name = "db-user-pass"
                key = "password"
	      }
	    }
          }
        }
      }
    }
  }
  timeouts {
    create = "3m"
  }
}

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
            name = "DB_USERNAME"
	    value = "user"
            value_from {
	      secret_key_ref {
                name = "db-user-pass"
	        key = "db_username"
	      }
            }
          }
          env {
            name = "DB_PASSWORD"
	    value = "passwd"
            value_from {
	      secret_key_ref {
	        name = "db-user-pass"
                key = "db_password"
	      }
	    }
          }
        }
      }
    }
  }
}

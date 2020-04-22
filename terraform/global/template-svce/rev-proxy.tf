resource "kubernetes_config_map" "nginx-config" {
  metadata {
    name = "nginx-config"
    namespace = "eo-services"
  }

  data = {   
    "nginx.conf" = "${file("${path.module}/nginx.cfg")}"
  }
  depends_on = [
    kubernetes_namespace.eo-services,
  ]
}

resource "kubernetes_service" "frontend" {
  metadata {
    name = "frontend"
    namespace = "eo-services"
  }
  spec {
    selector = {
      app = "template-service"
	  tier = "frontend"
    }
    
	port {
      port        = 8081
      target_port = 80
    }

    type = "LoadBalancer"
  }
  depends_on = [
    kubernetes_namespace.eo-services,                                                                                                              ]
}

resource "kubernetes_deployment" "frontend" {
  metadata {
    name = "frontend"
    namespace = "eo-services"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "template-service"
		tier = "frontend"
      }
    }

    template {
      metadata {
       labels = {
          app = "template-service"
		  tier = "frontend"
        }
      }

      spec {
        container {
          image = "nginx:1.7.9"
          name  = "nginx"

          lifecycle {
		    pre_stop {
				exec {
				  command = ["/usr/sbin/nginx","-s","quit"]
				}
			}
		  }
		  
		  volume_mount {
		    name = "config-volume"
			mount_path = "/etc/nginx/nginx.conf"
			sub_path = "nginx.conf"
		  }
		}  
		volume {
		  name = "config-volume"
		  config_map {
			name = "nginx-config"
		  }
		}
      }
    }
  }
  timeouts {
    create = "2m"
  }
  depends_on = [
    kubernetes_namespace.eo-services,                                                                                                              ]
}

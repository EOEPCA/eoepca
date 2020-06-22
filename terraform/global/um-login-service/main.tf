# Install NGINX ingress controller
#module "ingress-nginx" {
#  source  = "essjayhch/ingress-nginx/kubernetes"
#  version = "0.0.4"
#}
#
#resource "null_resource" "waitfor-ingress" {
#  provisioner "local-exec" {
#    command = <<EOT
#    while [ -z $external_ip ]; do echo "Waiting for end point..."; external_ip=$(kubectl get svc nginx-ingress-controller-ingress-nginx -n ingress-nginx --template="{{range .status.loadBalancer.ingress}}{{.ip}}{{end}}"); [ -z "$external_ip" ] && sleep 30; done; echo "End point ready-" && echo $external_ip; cf_export endpoint=$external_ip
#EOT
#  } 
#}
#
#data "kubernetes_service" "nginx-ingress-controller-ingress-nginx" {
#  metadata {
#    name = "nginx-ingress-controller-ingress-nginx"
#    namespace = "ingress-nginx"
#  }
#  depends_on = [ null_resource.waitfor-ingress ]
#}
#
#output "lb_address" {
#  value = data.kubernetes_service.nginx-ingress-controller-ingress-nginx.load_balancer_ingress.0.hostname
#}

module "nginx-ingress-controller" {
  source  = "byuoitav/nginx-ingress-controller/kubernetes"
  version = "0.1.13"
}

output "lb_address" {
  value = module.nginx-ingress-controller.lb_address
}


# Apply config
module "config" {
  source   = "./config"
  nginx_ip = module.nginx-ingress-controller.lb_address # data.kubernetes_service.nginx-ingress-controller-ingress-nginx.load_balancer_ingress.0.hostname
  hostname = var.hostname
}

# Apply LDAP
module "ldap" {
 source = "./ldap"
}

# Enable Ingress
module "nginx" {
 source   = "./nginx"
 nginx_ip = module.nginx-ingress-controller.lb_address # data.kubernetes_service.nginx-ingress-controller-ingress-nginx.load_balancer_ingress.0.hostname
 hostname = var.hostname
}

module "oxauth" {
 source   = "./oxauth"
 nginx_ip = module.nginx-ingress-controller.lb_address # data.kubernetes_service.nginx-ingress-controller-ingress-nginx.load_balancer_ingress.0.hostname
 hostname = var.hostname
}

module "oxtrust" {
   source = "./oxtrust"
   nginx_ip = module.nginx-ingress-controller.lb_address # data.kubernetes_service.nginx-ingress-controller-ingress-nginx.load_balancer_ingress.0.hostname
}

module "oxpassport" {
   source = "./oxpassport"
   nginx_ip = module.nginx-ingress-controller.lb_address # data.kubernetes_service.nginx-ingress-controller-ingress-nginx.load_balancer_ingress.0.hostname
   hostname = var.hostname
}
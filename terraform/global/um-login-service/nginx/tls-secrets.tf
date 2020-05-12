resource "null_resource" "tls-secrets" {
  provisioner "local-exec" {
    command = <<EOT
    ../global/um-login-service/nginx/tls-secrets.sh
EOT
  } # until kubectl get pods | grep "config-init" | grep "Completed"; do sleep 1; done
}

data "template_file" "dhparam_pem" {
  template = file("./dhparam.pem")
}

resource "kubernetes_secret" "tls-dhparam" {
  metadata {
     name = "tls-dhparam"
   }
  
  data = {
    "dhparam.pem" = "{data.template_file.dhparam_pem.template}"
  }

  type = "kubernetes.io/generic"

  depends_on = [ null_resource.tls-secrets ]
} # secret generic tls-dhparam --from-file=dhparam.pem

resource "kubernetes_secret" "tls-certificate" {
  metadata {
    name = "tls-certificate"
  }

  data = {
    "tls.crt" = file("./ingress.crt")
    "tls.key" = file("./ingress.key")
  }

  type = "kubernetes.io/tls"
} # kubectl create secret tls tls-certificate --key ingress.key --cert ingress.crt
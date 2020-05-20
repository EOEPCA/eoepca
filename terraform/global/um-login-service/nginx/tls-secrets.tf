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

  depends_on = [ null_resource.waitfor-tls-secrets, null_resource.waitfor-persistence ]
} # secret generic tls-dhparam --from-file=dhparam.pem

data "kubernetes_secret" "gluu" {
  metadata {
    name = "gluu"
  }
  depends_on = [ null_resource.waitfor-tls-secrets, null_resource.waitfor-persistence ]
} 

resource "local_file" "ingress_crt" {
  content = data.kubernetes_secret.gluu.data.ssl_cert
  filename = "./ingress.crt"

  depends_on = [ null_resource.waitfor-tls-secrets, null_resource.waitfor-persistence ]
}# kubectl get secret gluu -o json | grep '\"ssl_cert' | awk -F '"' '{print $4}' | base64 --decode > ingress.crt

resource "local_file" "ingress_key" {
  content = data.kubernetes_secret.gluu.data.ssl_key
  filename = "./ingress.key"

  depends_on = [ null_resource.waitfor-tls-secrets, null_resource.waitfor-persistence ]
} # kubectl get secret gluu -o json | grep '\"ssl_key' | awk -F '"' '{print $4}' | base64 --decode > ingress.key

resource "kubernetes_secret" "tls-certificate" {
  metadata {
    name = "tls-certificate"
  }

  data = {
    "tls.crt" = local_file.ingress_crt.filename
    "tls.key" = local_file.ingress_key.filename
  }

  type = "kubernetes.io/tls"

  depends_on = [ null_resource.waitfor-tls-secrets, null_resource.waitfor-persistence ]
} # kubectl create secret tls tls-certificate --key ingress.key --cert ingress.crt
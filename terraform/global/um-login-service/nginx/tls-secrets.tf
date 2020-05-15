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

resource "kubernetes_secret" "tls-certificate" {
  metadata {
    name = "tls-certificate"
  }

  data = {
    "tls.crt" = file("./ingress.crt")
    "tls.key" = file("./ingress.key")
  }

  type = "kubernetes.io/tls"

  depends_on = [ null_resource.waitfor-tls-secrets, null_resource.waitfor-persistence ]
} # kubectl create secret tls tls-certificate --key ingress.key --cert ingress.crt
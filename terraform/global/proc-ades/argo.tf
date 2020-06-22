resource "kubernetes_namespace" "argo" {
  metadata {
    name = "argo"
  }
}

resource "kubectl_manifest" "argo" {
  yaml_body = file("${path.module}/argo.yml")
}

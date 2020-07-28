resource "kubernetes_config_map" "ades_argo" {
  metadata {
    name = "ades-argo"
  }

  data = {
    "argo.json" = file("${path.module}/argo.json")
  }
}

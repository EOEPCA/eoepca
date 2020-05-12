resource "kubernetes_config_map" "config-cm" {
  metadata {
    name = "config-cm"
  }

  data = {
    "generate.json" = file("${path.module}/generate.json")
  }
}
resource "kubernetes_config_map" "config-cm" {
  metadata {
    name = "config-cm"
  }

  data = {
    # "generate.json" = file("${path.module}/generate.json") ### TODO CHANGE HOSTNAME
    "generate.json" = templatefile("${var.config_file}", { hostname = var.hostname })
  }
}
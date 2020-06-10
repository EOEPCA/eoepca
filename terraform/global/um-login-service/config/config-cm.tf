resource "kubernetes_config_map" "config-cm" {
  metadata {
    name = "config-cm"
  }

  data = {
    "generate.json" = file("${path.module}/generate.json") ### TODO CHANGE HOSTNAME
  }

  provisioner "local-exec" {
    command =   <<EOT
      echo "Adding ${var.nginx_ip} ${var.hostname} to /etc/hosts"
      sudo sed -i.bak -e '$a\' -e "${var.nginx_ip}\t\t${var.hostname}.domain\t${var.hostname}" -e "/.*${var.hostname}/d" /etc/hosts
    EOT
  }
}
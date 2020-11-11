resource "null_resource" "ades_roles" {
  provisioner "local-exec" {
    command = <<-EOT
      STORAGE_CLASS=${var.dynamic_storage_class} ${path.module}/ades.sh roles
      EOT
  }
}

data "local_file" "ades_yaml_roles" {
  depends_on = ["null_resource.ades_roles"]
  filename = "${path.module}/generated/ades.yaml"
}

resource "kubectl_manifest" "ades_roles" {
  yaml_body = data.local_file.ades_yaml_roles.content
}

resource "null_resource" "ades" {
  depends_on = ["kubectl_manifest.ades_roles"]
  provisioner "local-exec" {
    command = <<-EOT
      STORAGE_CLASS=${var.dynamic_storage_class} ${path.module}/ades.sh prepare
      EOT
  }
}

data "local_file" "ades_yaml" {
  depends_on = ["null_resource.ades"]
  filename = "${path.module}/generated/ades.yaml"
}

resource "kubectl_manifest" "ades" {
  yaml_body = data.local_file.ades_yaml.content
}

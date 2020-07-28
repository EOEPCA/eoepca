resource "null_resource" "waitfor-persistence" {
  depends_on = [ var.module_depends_on ]
  provisioner "local-exec" {
    command = <<EOT
    until kubectl get pods | grep "persistence" | grep "Completed"; do echo "Waiting for persistence" && sleep 30; done
EOT
  } 
}

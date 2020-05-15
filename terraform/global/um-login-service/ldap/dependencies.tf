resource "null_resource" "waitfor-opendj-init" {
  provisioner "local-exec" {
    command = <<EOT
    until kubectl logs opendj-init-0 | grep "Started listening for new connections on LDAPS Connection Handler"; do echo "Waiting for opendj-init0" && sleep 30; done
EOT
  } 
}

resource "null_resource" "waitfor-config-init" {
  provisioner "local-exec" {
    command = <<EOT
    until kubectl get pods | grep "config-init" | grep "Completed"; do echo "Waiting for config-init pod" && sleep 30; done
EOT
  } 
}
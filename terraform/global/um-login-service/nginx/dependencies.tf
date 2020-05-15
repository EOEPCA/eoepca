resource "null_resource" "waitfor-tls-secrets" {
  provisioner "local-exec" {
    command = <<EOT
    until kubectl get pods | grep "config-init" | grep "Completed"; do echo "Waiting for config-init pod" && sleep 30; done
    ../global/um-login-service/nginx/tls-secrets.sh
EOT
  } 
}

resource "null_resource" "waitfor-persistence" {
  provisioner "local-exec" {
    command = <<EOT
    until kubectl get pods | grep "persistence" | grep "Completed"; do echo "Waiting for persistence" && sleep 30; done
EOT
  } 
}
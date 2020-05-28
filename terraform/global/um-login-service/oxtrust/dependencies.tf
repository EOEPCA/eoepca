resource "null_resource" "waitfor-persistence" {
  provisioner "local-exec" {
    command = <<EOT
    until kubectl get pods | grep "persistence" | grep "Completed"; do echo "Waiting for persistence" && sleep 30; done
EOT
  } 
}

resource "null_resource" "waitfor-oxauth" {
    provisioner "local-exec" {
    command = <<EOT
      until [ `kubectl logs service/oxauth | grep "Server:main: Started" | wc -l` -ge 1 ]; do echo "Waiting for service/oxauth" && sleep 30; done
    EOT
  }
}

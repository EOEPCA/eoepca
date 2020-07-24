resource "null_resource" "waitfor-login-service" {
  provisioner "local-exec" {
    command = <<EOT
    until [ `kubectl logs service/oxauth | grep "Server:main: Started" | wc -l` -ge 1 ]; do echo "Waiting for Login Service" && sleep 30; done
EOT
  } 
}
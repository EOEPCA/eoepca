resource "null_resource" "waitfor-login-service" {
  depends_on = [ var.module_depends_on ]
  provisioner "local-exec" {
    command = <<EOT
    until [ `kubectl logs service/oxauth | grep "Server:main: Started" | wc -l` -ge 1 ]; do echo "Waiting for Login Service" && sleep 30; done
EOT
  }
}
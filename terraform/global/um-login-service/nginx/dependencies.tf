resource "null_resource" "waitfor-config-init" {
  depends_on = [var.module_depends_on]
}

resource "null_resource" "waitfor-module-depends" {
  depends_on = [var.module_depends_on]
}

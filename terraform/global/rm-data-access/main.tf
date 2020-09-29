resource "helm_release" "database" {
  name       = "data-access-database"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "postgresql"
  version    = "9.7.2"

  values = [
    "${file("../global/rm-data-access/values.yaml")}"
  ]

}

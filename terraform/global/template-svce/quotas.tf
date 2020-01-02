resource "kubernetes_resource_quota" "batch-job" {
  metadata {
    name = "batch-job"
	namespace = "eo-user-compute"
  }
  spec {
    hard = {
      pods = 10
    }
  }
  depends_on = [
    kubernetes_namespace.eo-user-compute,
  ]
}

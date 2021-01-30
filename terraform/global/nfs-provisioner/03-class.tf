resource "kubernetes_storage_class" "managed_nfs_storage" {
  metadata {
    name = "managed-nfs-storage"
  }
  storage_provisioner = "nfs-storage"
  reclaim_policy = "Retain"
}

# resource "kubernetes_storage_class" "ractest_nfs_storage" {
#   metadata {
#     name = "ractest-nfs-storage"
#   }
#   storage_provisioner = "ractest-storage"
#   reclaim_policy = "Retain"
# }

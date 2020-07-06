resource "kubernetes_storage_class" "managed_nfs_storage" {
  metadata {
    name = "managed-nfs-storage"
  }
  storage_provisioner = "nfs-storage"
  reclaim_policy = "Retain"
}

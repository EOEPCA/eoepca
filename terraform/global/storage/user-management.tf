resource "kubernetes_persistent_volume" "eoepca_userman_pv" {
  metadata {
    name = "eoepca-userman-pv"
    labels = {
      eoepca_type = "userman"
    }
  }
  spec {
    storage_class_name = "eoepca-nfs"
    access_modes       = ["ReadWriteMany"]
    capacity = {
      storage = "5Gi"
    }
    persistent_volume_source {
      nfs {
        server = var.nfs_server_address
        path = "/data/userman"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "eoepca_userman_pvc" {
  metadata {
    name = "eoepca-userman-pvc"
    labels = {
      eoepca_type = "userman"
    }
  }
  spec {
    storage_class_name = "eoepca-nfs"
    access_modes = ["ReadWriteMany"]
    resources {
      requests = {
        storage = "3Gi"
      }
    }
    selector {
      match_labels = {
        eoepca_type = "userman"
      }
    }
  }
}

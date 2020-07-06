resource "kubernetes_persistent_volume" "eoepca_resman_pv" {
  metadata {
    name = "eoepca-resman-pv"
    labels = {
      eoepca_type = "resman"
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
        path = "/data/resman"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "eoepca_resman_pvc" {
  metadata {
    name = "eoepca-resman-pvc"
    labels = {
      eoepca_type = "resman"
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
        eoepca_type = "resman"
      }
    }
  }
}

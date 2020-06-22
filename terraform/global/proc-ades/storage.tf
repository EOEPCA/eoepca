resource "kubernetes_persistent_volume" "eoepca_pv" {
  metadata {
    name = "eoepca-pv"
    labels = {
      eoepca_type = "ades"
    }
  }
  spec {
    storage_class_name = "eoepca"
    access_modes       = ["ReadWriteOnce"]
    capacity = {
      storage = "5Gi"
    }
    persistent_volume_source {
      host_path {
        path = "/mnt/eoepca/ades"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "eoepca_pvc" {
  metadata {
    name = "eoepca-pvc"
    labels = {
      eoepca_type = "ades"
    }
  }
  spec {
    storage_class_name = "eoepca"
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "3Gi"
      }
    }
    selector {
      match_labels = {
        eoepca_type = "ades"
      }
    }
  }
}

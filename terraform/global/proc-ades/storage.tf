resource "kubernetes_persistent_volume" "eoepca_pv" {
  metadata {
    name = "eoepca-pv"

    labels = {
      type = "local"
    }
  }

  spec {
    capacity = {
      storage = "5Gi"
    }

    access_modes       = ["ReadWriteOnce"]
    storage_class_name = "ades"
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
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    resources {
      requests = {
        storage = "3Gi"
      }
    }

    storage_class_name = "ades"
  }
}


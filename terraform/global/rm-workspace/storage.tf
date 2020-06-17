resource "kubernetes_persistent_volume" "workspace_pv" {
  metadata {
    name = "workspace-pv"

    labels = {
      type = "local"
    }
  }

  spec {
    capacity = {
      storage = "5Gi"
    }

    access_modes       = ["ReadWriteOnce"]
    storage_class_name = "workspace"
    persistent_volume_source {
      host_path {
        path = "/mnt/eoepca/workspace"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "workspace_pvc" {
  metadata {
    name = "workspace-pvc"
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    resources {
      requests = {
        storage = "3Gi"
      }
    }

    storage_class_name = "workspace"
  }
}


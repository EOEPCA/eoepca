resource "kubernetes_persistent_volume" "workspace_pv" {
  metadata {
    name = "workspace-pv"
    labels = {
      eoepca_type = "workspace"
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
        path = "/mnt/eoepca/workspace"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "workspace_pvc" {
  metadata {
    name = "workspace-pvc"
    labels = {
      eoepca_type = "workspace"
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
        eoepca_type = "workspace"
      }
    }
  }
}

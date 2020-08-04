resource "kubernetes_persistent_volume" "eoepca_proc_pv" {
  count = "${var.storage_class == "eoepca-nfs" ? 1 : 0}"
  metadata {
    name = "eoepca-proc-pv"
    labels = {
      eoepca_type = "proc"
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
        path = "/data/proc"
      }
    }
  }
}

resource "kubernetes_persistent_volume" "eoepca_proc_pv_host" {
  count = "${var.storage_class == "standard" ? 1 : 0}"
  metadata {
    name = "eoepca-proc-pv-host"
    labels = {
      eoepca_type = "proc"
    }
  }
  spec {
    storage_class_name = "standard"
    access_modes       = ["ReadWriteMany"]
    capacity = {
      storage = "5Gi"
    }
    persistent_volume_source {
      host_path {
        path = "/kubedata/proc"
        type = "DirectoryOrCreate"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "eoepca_pvc" {
  metadata {
    name = "eoepca-pvc"
    labels = {
      eoepca_type = "proc"
    }
  }
  spec {
    storage_class_name = var.storage_class
    access_modes = ["ReadWriteMany"]
    resources {
      requests = {
        storage = "3Gi"
      }
    }
    selector {
      match_labels = {
        eoepca_type = "proc"
      }
    }
  }
}

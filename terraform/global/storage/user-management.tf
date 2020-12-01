resource "kubernetes_persistent_volume" "eoepca_userman_pv" {
  count = "${var.storage_class == "eoepca-nfs" ? 1 : 0}"
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
        path   = "/data/userman"
      }
    }
  }
}

resource "kubernetes_persistent_volume" "eoepca_userman_pv_host" {
  count = "${var.storage_class == "eoepca-nfs" ? 0 : 1}"
  metadata {
    name = "eoepca-userman-pv-host"
    labels = {
      eoepca_type = "userman"
    }
  }
  spec {
    storage_class_name = var.storage_class
    access_modes       = ["ReadWriteMany"]
    capacity = {
      storage = "5Gi"
    }
    persistent_volume_source {
      host_path {
        path = "/kubedata/userman"
        type = "DirectoryOrCreate"
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
    storage_class_name = var.storage_class
    access_modes       = ["ReadWriteMany"]
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





resource "kubernetes_persistent_volume" "eoepca_pep_pv_host" {
  count = "${var.storage_class == "eoepca-nfs" ? 0 : 1}"
  metadata {
    name = "eoepca-pep-pv-host"
    labels = {
      eoepca_type = "userman"
    }
  }
  spec {
    storage_class_name = var.storage_class
    access_modes       = ["ReadWriteMany"]
    capacity = {
      storage = "5Gi"
    }
    persistent_volume_source {
      host_path {
        path = "/kubedata/userman"
        type = "DirectoryOrCreate"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "eoepca-pep-pvc" {
  metadata {
    name = "eoepca-pep-pvc"
    labels = {
      eoepca_type = "userman"
    }
  }
  spec {
    storage_class_name = var.storage_class
    access_modes       = ["ReadWriteMany"]
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
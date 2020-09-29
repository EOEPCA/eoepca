resource "kubernetes_persistent_volume" "eoepca_resman_pv" {
  count = var.storage_class == "eoepca-nfs" ? 1 : 0
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
        path   = "/data/resman"
      }
    }
  }
}

resource "kubernetes_persistent_volume" "eoepca_resman_pv_host" {
  count = var.storage_class == "eoepca-nfs" ? 0 : 1
  metadata {
    name = "eoepca-resman-pv-host"
    labels = {
      eoepca_type = "resman"
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
        path = "/kubedata/resman"
        type = "DirectoryOrCreate"
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
    storage_class_name = var.storage_class
    access_modes       = ["ReadWriteMany"]
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



resource "kubernetes_persistent_volume" "eoepca_rm_db_pv" {
  count = var.storage_class == "eoepca-nfs" ? 1 : 0
  metadata {
    name = "eoepca-rm-db-pv"
    labels = {
      eoepca_type = "rm_db"
    }
  }
  spec {
    storage_class_name = "eoepca-nfs"
    access_modes       = ["ReadWriteOnce"]
    capacity = {
      storage = "20Gi"
    }
    persistent_volume_source {
      nfs {
        server = var.nfs_server_address
        path   = "/data/rm_db"
      }
    }
  }
}

resource "kubernetes_persistent_volume" "eoepca_rm_db_pv_host" {
  count = var.storage_class == "eoepca-nfs" ? 0 : 1
  metadata {
    name = "eoepca-rm-db-pv-host"
    labels = {
      eoepca_type = "rm_db"
    }
  }
  spec {
    storage_class_name = var.storage_class
    access_modes       = ["ReadWriteOnce"]
    capacity = {
      storage = "1Gi"
    }
    persistent_volume_source {
      host_path {
        path = "/kubedata/rm_db"
        type = "DirectoryOrCreate"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "eoepca_rm_db_pvc" {
  metadata {
    name = "eoepca-rm-db-pvc"
    labels = {
      eoepca_type = "rm_db"
    }
  }
  spec {
    storage_class_name = var.storage_class
    access_modes       = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "1Gi"
      }
    }
    selector {
      match_labels = {
        eoepca_type = "rm_db"
      }
    }
  }
}

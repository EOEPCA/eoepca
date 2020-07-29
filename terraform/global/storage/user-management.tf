resource "kubernetes_persistent_volume" "eoepca_userman_pv" {
  count = "${var.nfs_server_address == "none" ? 0 : 1}"
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
    storage_class_name = var.storage_class
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


resource "kubernetes_persistent_volume" "resource_persistent_storage" {
  metadata {
    name = "resource-persistent-storage"

    labels = {
      pep-engine = "resource-persistent-storage"
    }
  }

  spec {
    capacity = {
      storage = "10M"
    }

    access_modes = ["ReadWriteMany"]

    persistent_volume_source {
      host_path {
        path = "/data/db/resource"
      }
    }
    storage_class_name = "standard"
  }
}


resource "kubernetes_persistent_volume_claim" "resource_persistent_storage_volume_claim" {
  metadata {
    name = "resource-persistent-storage-volume-claim"
  }

  spec {
    access_modes = ["ReadWriteMany"]

    resources {
      requests = {
        storage = "10M"
      }
    }

    volume_name = "resource-persistent-storage"
  }
}

resource "kubernetes_persistent_volume" "policy_persistent_storage" {
  metadata {
    name = "policy-persistent-storage"

    labels = {
      pep-engine = "policy-persistent-storage"
    }
  }

  spec {
    capacity = {
      storage = "10M"
    }

    access_modes = ["ReadWriteMany"]

    persistent_volume_source {
      host_path {
        path = "/data/db/policy"
      }
    }
    storage_class_name = "standard"
  }
}


resource "kubernetes_persistent_volume_claim" "policy_persistent_storage_volume_claim" {
  metadata {
    name = "policy-persistent-storage-volume-claim"
  }

  spec {
    access_modes = ["ReadWriteMany"]

    resources {
      requests = {
        storage = "10M"
      }
    }

    volume_name = "policy-persistent-storage"
  }
}
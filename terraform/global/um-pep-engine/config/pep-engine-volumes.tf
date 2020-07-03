resource "kubernetes_persistent_volume_claim" "pep_engine_logs_volume_claim" {
  metadata {
    name = "pep-engine-logs-volume-claim"
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    selector {
      match_labels = {
        pep-engine = "logs"
      }
    }

    resources {
      requests = {
        storage = "10M"
      }
    }

    volume_name = "pep-engine-logs"
  }
}

resource "kubernetes_persistent_volume" "mongo_persistent_storage" {
  metadata {
    name = "mongo-persistent-storage"

    labels = {
      pep-engine = "mongo-persistent-storage"
    }
  }

  spec {
    capacity = {
      storage = "10M"
    }

    access_modes = ["ReadWriteMany"]

    persistent_volume_source {
      host_path {
        path = "/data/db"
      }
    }
    storage_class_name = "standard"
  }
}


resource "kubernetes_persistent_volume_claim" "mongo_persistent_storage_volume_claim" {
  metadata {
    name = "mongo-persistent-storage-volume-claim"
  }

  spec {
    access_modes = ["ReadWriteMany"]

    resources {
      requests = {
        storage = "10M"
      }
    }

    volume_name = "mongo-persistent-storage"
  }
}

resource "kubernetes_persistent_volume_claim" "pep_engine_lib_ext_volume_claim" {
  metadata {
    name = "pep-engine-lib-ext-volume-claim"
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    selector {
      match_labels = {
        pep-engine = "lib-ext"
      }
    }

    resources {
      requests = {
        storage = "10M"
      }
    }

    volume_name = "pep-engine-lib-ext"
  }
}

resource "kubernetes_persistent_volume_claim" "pep_engine_custom_static_volume_claim" {
  metadata {
    name = "pep-engine-custom-static-volume-claim"
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    selector {
      match_labels = {
        pep-engine = "custom-static"
      }
    }

    resources {
      requests = {
        storage = "10M"
      }
    }

    volume_name = "pep-engine-custom-static"
  }
}

resource "kubernetes_persistent_volume_claim" "pep_engine_custom_pages_volume_claim" {
  metadata {
    name = "pep-engine-custom-pages-volume-claim"
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    selector {
      match_labels = {
        pep-engine = "custom-pages"
      }
    }

    resources {
      requests = {
        storage = "10M"
      }
    }

    volume_name = "pep-engine-custom-pages"
  }
}

resource "kubernetes_persistent_volume" "pep_engine_logs" {
  metadata {
    name = "pep-engine-logs"

    labels = {
      pep-engine = "logs"
    }
  }

  spec {
    capacity = {
      storage = "10M"
    }

    access_modes = ["ReadWriteOnce"]

    persistent_volume_source {
      host_path {
        path = "/data/pep-engine/logs"
      }
    }
    storage_class_name = "standard"
  }
}

resource "kubernetes_persistent_volume" "pep_engine_lib_ext" {
  metadata {
    name = "pep-engine-lib-ext"

    labels = {
      pep-engine = "lib-ext"
    }
  }


  spec {
    capacity = {
      storage = "10M"
    }

    access_modes = ["ReadWriteOnce"]

    persistent_volume_source {
      host_path {
        path = "/data/pep-engine/custom/libs"
      }
    }
    storage_class_name = "standard"
  }
}

resource "kubernetes_persistent_volume" "pep_engine_custom_static" {
  metadata {
    name = "pep-engine-custom-static"

    labels = {
      pep-engine = "custom-static"
    }
  }

  spec {
    capacity = {
      storage = "10M"
    }

    access_modes = ["ReadWriteOnce"]

    persistent_volume_source {
      host_path {
        path = "/data/pep-engine/custom/static"
      }
    }
    storage_class_name = "standard"
  }
}

resource "kubernetes_persistent_volume" "pep_engine_custom_pages" {
  metadata {
    name = "pep-engine-custom-pages"

    labels = {
      pep-engine = "custom-pages"
    }
  }

  spec {
    capacity = {
      storage = "10M"
    }

    access_modes = ["ReadWriteOnce"]

    persistent_volume_source {
      host_path {
        path = "/data/pep-engine/custom/pages"
      }
    }
    storage_class_name = "standard"
  }
}
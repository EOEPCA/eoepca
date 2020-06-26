resource "kubernetes_persistent_volume_claim" "mongo_sidecar_logs_volume_claim" {
  metadata {
    name = "mongo-sidecar-logs-volume-claim"
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    selector {
      match_labels = {
        mongo-sidecar = "logs"
      }
    }

    resources {
      requests = {
        storage = "10M"
      }
    }

    volume_name = "mongo-sidecar-logs"
  }
}

resource "kubernetes_persistent_volume_claim" "mongo_sidecar_lib_ext_volume_claim" {
  metadata {
    name = "mongo-sidecar-lib-ext-volume-claim"
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    selector {
      match_labels = {
        mongo-sidecar = "lib-ext"
      }
    }

    resources {
      requests = {
        storage = "10M"
      }
    }

    volume_name = "mongo-sidecar-lib-ext"
  }
}

resource "kubernetes_persistent_volume_claim" "mongo_sidecar_custom_static_volume_claim" {
  metadata {
    name = "mongo-sidecar-custom-static-volume-claim"
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    selector {
      match_labels = {
        mongo-sidecar = "custom-static"
      }
    }

    resources {
      requests = {
        storage = "10M"
      }
    }

    volume_name = "mongo-sidecar-custom-static"
  }
}

resource "kubernetes_persistent_volume_claim" "mongo_sidecar_custom_pages_volume_claim" {
  metadata {
    name = "mongo-sidecar-custom-pages-volume-claim"
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    selector {
      match_labels = {
        mongo-sidecar = "custom-pages"
      }
    }

    resources {
      requests = {
        storage = "10M"
      }
    }

    volume_name = "mongo-sidecar-custom-pages"
  }
}

resource "kubernetes_persistent_volume" "mongo_sidecar_logs" {
  metadata {
    name = "mongo-sidecar-logs"

    labels = {
      mongo-sidecar = "logs"
    }
  }

  spec {
    capacity = {
      storage = "10M"
    }

    access_modes = ["ReadWriteOnce"]

    persistent_volume_source {
      host_path {
        path = "/data/mongo-sidecar/logs"
      }
    }
    storage_class_name = "standard"
  }
}

resource "kubernetes_persistent_volume" "mongo_sidecar_lib_ext" {
  metadata {
    name = "mongo-sidecar-lib-ext"

    labels = {
      mongo-sidecar = "lib-ext"
    }
  }


  spec {
    capacity = {
      storage = "10M"
    }

    access_modes = ["ReadWriteOnce"]

    persistent_volume_source {
      host_path {
        path = "/data/mongo-sidecar/custom/libs"
      }
    }
    storage_class_name = "standard"
  }
}

resource "kubernetes_persistent_volume" "mongo_sidecar_custom_static" {
  metadata {
    name = "mongo-sidecar-custom-static"

    labels = {
      mongo-sidecar = "custom-static"
    }
  }

  spec {
    capacity = {
      storage = "10M"
    }

    access_modes = ["ReadWriteOnce"]

    persistent_volume_source {
      host_path {
        path = "/data/mongo-sidecar/custom/static"
      }
    }
    storage_class_name = "standard"
  }
}

resource "kubernetes_persistent_volume" "mongo_sidecar_custom_pages" {
  metadata {
    name = "mongo-sidecar-custom-pages"

    labels = {
      mongo-sidecar = "custom-pages"
    }
  }

  spec {
    capacity = {
      storage = "10M"
    }

    access_modes = ["ReadWriteOnce"]

    persistent_volume_source {
      host_path {
        path = "/data/mongo-sidecar/custom/pages"
      }
    }
    storage_class_name = "standard"
  }
}
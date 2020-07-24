resource "kubernetes_persistent_volume_claim" "pdp_engine_logs_volume_claim" {
  metadata {
    name = "pdp-engine-logs-volume-claim"
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    selector {
      match_labels = {
        pdp-engine = "logs"
      }
    }

    resources {
      requests = {
        storage = "10M"
      }
    }

    volume_name = "pdp-engine-logs"
  }
}

resource "kubernetes_persistent_volume" "mongo_persistent_storage" {
  metadata {
    name = "mongo-persistent-storage"

    labels = {
      pdp-engine = "mongo-persistent-storage"
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

resource "kubernetes_persistent_volume_claim" "pdp_engine_lib_ext_volume_claim" {
  metadata {
    name = "pdp-engine-lib-ext-volume-claim"
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    selector {
      match_labels = {
        pdp-engine = "lib-ext"
      }
    }

    resources {
      requests = {
        storage = "10M"
      }
    }

    volume_name = "pdp-engine-lib-ext"
  }
}

resource "kubernetes_persistent_volume_claim" "pdp_engine_custom_static_volume_claim" {
  metadata {
    name = "pdp-engine-custom-static-volume-claim"
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    selector {
      match_labels = {
        pdp-engine = "custom-static"
      }
    }

    resources {
      requests = {
        storage = "10M"
      }
    }

    volume_name = "pdp-engine-custom-static"
  }
}

resource "kubernetes_persistent_volume_claim" "pdp_engine_custom_pages_volume_claim" {
  metadata {
    name = "pdp-engine-custom-pages-volume-claim"
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    selector {
      match_labels = {
        pdp-engine = "custom-pages"
      }
    }

    resources {
      requests = {
        storage = "10M"
      }
    }

    volume_name = "pdp-engine-custom-pages"
  }
}

resource "kubernetes_persistent_volume" "pdp_engine_logs" {
  metadata {
    name = "pdp-engine-logs"

    labels = {
      pdp-engine = "logs"
    }
  }

  spec {
    capacity = {
      storage = "10M"
    }

    access_modes = ["ReadWriteOnce"]

    persistent_volume_source {
      host_path {
        path = "/data/pdp-engine/logs"
      }
    }
    storage_class_name = "standard"
  }
}

resource "kubernetes_persistent_volume" "pdp_engine_lib_ext" {
  metadata {
    name = "pdp-engine-lib-ext"

    labels = {
      pdp-engine = "lib-ext"
    }
  }


  spec {
    capacity = {
      storage = "10M"
    }

    access_modes = ["ReadWriteOnce"]

    persistent_volume_source {
      host_path {
        path = "/data/pdp-engine/custom/libs"
      }
    }
    storage_class_name = "standard"
  }
}

resource "kubernetes_persistent_volume" "pdp_engine_custom_static" {
  metadata {
    name = "pdp-engine-custom-static"

    labels = {
      pdp-engine = "custom-static"
    }
  }

  spec {
    capacity = {
      storage = "10M"
    }

    access_modes = ["ReadWriteOnce"]

    persistent_volume_source {
      host_path {
        path = "/data/pdp-engine/custom/static"
      }
    }
    storage_class_name = "standard"
  }
}

resource "kubernetes_persistent_volume" "pdp_engine_custom_pages" {
  metadata {
    name = "pdp-engine-custom-pages"

    labels = {
      pdp-engine = "custom-pages"
    }
  }

  spec {
    capacity = {
      storage = "10M"
    }

    access_modes = ["ReadWriteOnce"]

    persistent_volume_source {
      host_path {
        path = "/data/pdp-engine/custom/pages"
      }
    }
    storage_class_name = "standard"
  }
}
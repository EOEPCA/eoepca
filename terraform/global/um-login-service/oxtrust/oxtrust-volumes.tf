resource "kubernetes_persistent_volume_claim" "oxtrust_logs_volume_claim" {
  metadata {
    name = "oxtrust-logs-volume-claim"
  }

  timeouts {
    create = "15m"
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    selector {
      match_labels = {
        oxtrust = "logs"
      }
    }

    resources {
      requests = {
        storage = "10M"
      }
    }

    volume_name = "oxtrust-logs"
  }
}

resource "kubernetes_persistent_volume_claim" "oxtrust_lib_ext_volume_claim" {
  metadata {
    name = "oxtrust-lib-ext-volume-claim"
  }

  timeouts {
    create = "15m"
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    selector {
      match_labels = {
        oxtrust = "lib-ext"
      }
    }

    resources {
      requests = {
        storage = "10M"
      }
    }

    volume_name = "oxtrust-lib-ext"
  }
}

resource "kubernetes_persistent_volume_claim" "oxtrust_custom_static_volume_claim" {
  metadata {
    name = "oxtrust-custom-static-volume-claim"
  }

  timeouts {
    create = "15m"
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    selector {
      match_labels = {
        oxtrust = "custom-static"
      }
    }

    resources {
      requests = {
        storage = "10M"
      }
    }

    volume_name = "oxtrust-custom-static"
  }
}

resource "kubernetes_persistent_volume_claim" "oxtrust_custom_pages_volume_claim" {
  metadata {
    name = "oxtrust-custom-pages-volume-claim"
  }

  timeouts {
    create = "15m"
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    selector {
      match_labels = {
        oxtrust = "custom-pages"
      }
    }

    resources {
      requests = {
        storage = "10M"
      }
    }

    volume_name = "oxtrust-custom-pages"
  }
}

resource "kubernetes_persistent_volume" "oxtrust_logs" {
  metadata {
    name = "oxtrust-logs"

    labels = {
      oxtrust = "logs"
    }
  }

  timeouts {
    create = "15m"
  }

  spec {
    capacity = {
      storage = "10M"
    }
    access_modes = ["ReadWriteOnce"]

    persistent_volume_source {
      host_path {
        path = "/data/oxtrust/logs"
      }
    }
    storage_class_name = "standard"
  }
}

resource "kubernetes_persistent_volume" "oxtrust_lib_ext" {
  metadata {
    name = "oxtrust-lib-ext"

    labels = {
      oxtrust = "lib-ext"
    }
  }

  timeouts {
    create = "15m"
  }

  spec {
    capacity = {
      storage = "10M"
    }

    access_modes = ["ReadWriteOnce"]

    persistent_volume_source {
      host_path {
        path = "/data/oxtrust/custom/libs"
      }
    }
    storage_class_name = "standard"
  }
}

resource "kubernetes_persistent_volume" "oxtrust_custom_static" {
  metadata {
    name = "oxtrust-custom-static"

    labels = {
      oxtrust = "custom-static"
    }
  }

  timeouts {
    create = "15m"
  }

  spec {
    capacity = {
      storage = "10M"
    }

    access_modes = ["ReadWriteOnce"]

    persistent_volume_source {
      host_path {
        path = "/data/oxtrust/custom/static"
      }
    }
    storage_class_name = "standard"
  }
}

resource "kubernetes_persistent_volume" "oxtrust_custom_pages" {
  metadata {
    name = "oxtrust-custom-pages"

    labels = {
      oxtrust = "custom-pages"
    }
  }

  timeouts {
    create = "15m"
  }

  spec {
    capacity = {
      storage = "10M"
    }

    access_modes = ["ReadWriteOnce"]

    persistent_volume_source {
      host_path {
        path = "/data/oxtrust/custom/pages"
        # This is useful for single-node development and testing only! On-host storage is not supported in any way and WILL NOT WORK in a multi-node cluster. 
      }
    }
    storage_class_name = "standard"
  }
}


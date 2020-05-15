resource "kubernetes_persistent_volume_claim" "oxauth_logs_volume_claim" {
  metadata {
    name = "oxauth-logs-volume-claim"
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    selector {
      match_labels = {
        oxauth = "logs"
      }
    }

    resources {
      requests = {
        storage = "10M"
      }
    }

    volume_name = "oxauth-logs"
  }
}

resource "kubernetes_persistent_volume_claim" "oxauth_lib_ext_volume_claim" {
  metadata {
    name = "oxauth-lib-ext-volume-claim"
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    selector {
      match_labels = {
        oxauth = "lib-ext"
      }
    }

    resources {
      requests = {
        storage = "10M"
      }
    }

    volume_name = "oxauth-lib-ext"
  }
}

resource "kubernetes_persistent_volume_claim" "oxauth_custom_static_volume_claim" {
  metadata {
    name = "oxauth-custom-static-volume-claim"
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    selector {
      match_labels = {
        oxauth = "custom-static"
      }
    }

    resources {
      requests = {
        storage = "10M"
      }
    }

    volume_name = "oxauth-custom-static"
  }
}

resource "kubernetes_persistent_volume_claim" "oxauth_custom_pages_volume_claim" {
  metadata {
    name = "oxauth-custom-pages-volume-claim"
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    selector {
      match_labels = {
        oxauth = "custom-pages"
      }
    }

    resources {
      requests = {
        storage = "10M"
      }
    }

    volume_name = "oxauth-custom-pages"
  }
}

resource "kubernetes_persistent_volume" "oxauth_logs" {
  metadata {
    name = "oxauth-logs"

    labels = {
      oxauth = "logs"
    }
  }

  spec {
    capacity = {
      storage = "10M"
    }

    access_modes = ["ReadWriteOnce"]

    persistent_volume_source {
      host_path {
        path = "/data/oxauth/logs"
      }
    }
    storage_class_name = "standard"
  }
}

resource "kubernetes_persistent_volume" "oxauth_lib_ext" {
  metadata {
    name = "oxauth-lib-ext"

    labels = {
      oxauth = "lib-ext"
    }
  }


  spec {
    capacity = {
      storage = "10M"
    }

    access_modes = ["ReadWriteOnce"]

    persistent_volume_source {
      host_path {
        path = "/data/oxauth/custom/libs"
      }
    }
    storage_class_name = "standard"
  }
}

resource "kubernetes_persistent_volume" "oxauth_custom_static" {
  metadata {
    name = "oxauth-custom-static"

    labels = {
      oxauth = "custom-static"
    }
  }

  spec {
    capacity = {
      storage = "10M"
    }

    access_modes = ["ReadWriteOnce"]

    persistent_volume_source {
      host_path {
        path = "/data/oxauth/custom/static"
      }
    }
    storage_class_name = "standard"
  }
}

resource "kubernetes_persistent_volume" "oxauth_custom_pages" {
  metadata {
    name = "oxauth-custom-pages"

    labels = {
      oxauth = "custom-pages"
    }
  }

  spec {
    capacity = {
      storage = "10M"
    }

    access_modes = ["ReadWriteOnce"]

    persistent_volume_source {
      host_path {
        path = "/data/oxauth/custom/pages"
      }
    }
    storage_class_name = "standard"
  }
}


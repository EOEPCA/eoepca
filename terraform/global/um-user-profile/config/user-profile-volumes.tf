resource "kubernetes_persistent_volume_claim" "user_profile_logs_volume_claim" {
  metadata {
    name = "user-profile-logs-volume-claim"
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    selector {
      match_labels = {
        user-profile = "logs"
      }
    }

    resources {
      requests = {
        storage = "10M"
      }
    }

    volume_name = "user-profile-logs"
  }
}

resource "kubernetes_persistent_volume_claim" "user_profile_lib_ext_volume_claim" {
  metadata {
    name = "user-profile-lib-ext-volume-claim"
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    selector {
      match_labels = {
        user-profile = "lib-ext"
      }
    }

    resources {
      requests = {
        storage = "10M"
      }
    }

    volume_name = "user-profile-lib-ext"
  }
}

resource "kubernetes_persistent_volume_claim" "user_profile_custom_static_volume_claim" {
  metadata {
    name = "user-profile-custom-static-volume-claim"
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    selector {
      match_labels = {
        user-profile = "custom-static"
      }
    }

    resources {
      requests = {
        storage = "10M"
      }
    }

    volume_name = "user-profile-custom-static"
  }
}

resource "kubernetes_persistent_volume" "user_profile_logs" {
  metadata {
    name = "user-profile-logs"

    labels = {
      user-profile = "logs"
    }
  }

  spec {
    capacity = {
      storage = "10M"
    }

    access_modes = ["ReadWriteOnce"]

    persistent_volume_source {
      host_path {
        path = "/data/user-profile/logs"
      }
    }
    storage_class_name = "standard"
  }
}

resource "kubernetes_persistent_volume" "user_profile_lib_ext" {
  metadata {
    name = "user-profile-lib-ext"

    labels = {
      user-profile = "lib-ext"
    }
  }


  spec {
    capacity = {
      storage = "10M"
    }

    access_modes = ["ReadWriteOnce"]

    persistent_volume_source {
      host_path {
        path = "/data/user-profile/custom/libs"
      }
    }
    storage_class_name = "standard"
  }
}

resource "kubernetes_persistent_volume" "user_profile_custom_static" {
  metadata {
    name = "user-profile-custom-static"

    labels = {
      user-profile = "custom-static"
    }
  }

  spec {
    capacity = {
      storage = "10M"
    }

    access_modes = ["ReadWriteOnce"]

    persistent_volume_source {
      host_path {
        path = "/data/user-profile/custom/static"
      }
    }
    storage_class_name = "standard"
  }
}

resource "kubernetes_persistent_volume" "user_profile_custom_pages" {
  metadata {
    name = "user-profile-custom-pages"

    labels = {
      user-profile = "custom-pages"
    }
  }

  spec {
    capacity = {
      storage = "10M"
    }

    access_modes = ["ReadWriteOnce"]

    persistent_volume_source {
      host_path {
        path = "/data/user-profile/custom/pages"
      }
    }
    storage_class_name = "standard"
  }
}
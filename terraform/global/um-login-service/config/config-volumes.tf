resource "kubernetes_persistent_volume_claim" "config_volume_claim" {
  metadata {
    name = "config-volume-claim"
  }

  timeouts {
    create = "15m"
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    selector {
      match_labels = {
        config-init = "config"
      }
    }

    resources {
      requests = {
        storage = "10M"
      }
    }

    volume_name = "config"
  }
}

resource "kubernetes_persistent_volume" "config" {
  metadata {
    name = "config"

    labels = {
      config-init = "config"
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
        path = "/data/config/db"
        type = "DirectoryOrCreate" # From Terraform reference: Represents a directory on the host. Provisioned by a developer or tester. This is useful for single-node development and testing only! On-host storage is not supported in any way and WILL NOT WORK in a multi-node cluster. For more info see Kubernetes reference
      }
    }
    storage_class_name = "standard"
  }
}


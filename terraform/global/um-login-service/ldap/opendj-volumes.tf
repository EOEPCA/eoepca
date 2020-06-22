resource "kubernetes_persistent_volume" "opendj_config" {
  metadata {
    name = "opendj-config"

    labels = {
      opendj = "config"
    }
  }

  spec {
    capacity = {
      storage = "100M"
    }

    access_modes = ["ReadWriteOnce"]

    persistent_volume_source {
      host_path {
        path = "/data/opendj/config"
        type = "DirectoryOrCreate" # From Terraform reference: Represents a directory on the host. Provisioned by a developer or tester. This is useful for single-node development and testing only! On-host storage is not supported in any way and WILL NOT WORK in a multi-node cluster. For more info see Kubernetes reference
      }
    }
    storage_class_name = "standard" 
  }
}

resource "kubernetes_persistent_volume" "opendj_ldif" {
  metadata {
    name = "opendj-ldif"

    labels = {
      opendj = "ldif"
    }
  }

  spec {
    capacity = {
      storage = "100M"
    }

    access_modes = ["ReadWriteOnce"]

    persistent_volume_source {
      host_path {
        path = "/data/opendj/ldif"
        type = "DirectoryOrCreate" # From Terraform reference: Represents a directory on the host. Provisioned by a developer or tester. This is useful for single-node development and testing only! On-host storage is not supported in any way and WILL NOT WORK in a multi-node cluster. For more info see Kubernetes reference
      }
    }
    storage_class_name = "standard" 
  }
}

resource "kubernetes_persistent_volume" "opendj_logs" {
  metadata {
    name = "opendj-logs"

    labels = {
      opendj = "logs"
    }
  }

  spec {
    capacity = {
      storage = "100M"
    }

    access_modes = ["ReadWriteOnce"]

    persistent_volume_source {
      host_path {
        path = "/data/opendj/logs"
        type = "DirectoryOrCreate" # From Terraform reference: Represents a directory on the host. Provisioned by a developer or tester. This is useful for single-node development and testing only! On-host storage is not supported in any way and WILL NOT WORK in a multi-node cluster. For more info see Kubernetes reference
      }
    }
    storage_class_name = "standard"
  }
}

resource "kubernetes_persistent_volume" "opendj_db" {
  metadata {
    name = "opendj-db"

    labels = {
      opendj = "db"
    }
  }

  spec {
    capacity = {
      storage = "5Gi"
    }

    access_modes = ["ReadWriteOnce"]

    persistent_volume_source {
      host_path {
        path = "/data/opendj/db"
        type = "DirectoryOrCreate" # From Terraform reference: Represents a directory on the host. Provisioned by a developer or tester. This is useful for single-node development and testing only! On-host storage is not supported in any way and WILL NOT WORK in a multi-node cluster. For more info see Kubernetes reference
      }
    }
    storage_class_name = "standard"
  }
}

resource "kubernetes_persistent_volume" "opendj_flag" {
  metadata {
    name = "opendj-flag"

    labels = {
      opendj = "flag"
    }
  }

  spec {
    capacity = {
      storage = "100M"
    }

    access_modes = ["ReadWriteOnce"]

    persistent_volume_source {
      host_path {
        path = "/data/opendj/flag"
        type = "DirectoryOrCreate" 
        # From Terraform reference: Represents a directory on the host. 
        # Provisioned by a developer or tester. 
        # This is useful for single-node development and testing only! 
        # On-host storage is not supported in any way and WILL NOT WORK in a multi-node cluster. 
        # For more info see Kubernetes reference
      }
    }
    storage_class_name = "standard"
  }
}

resource "kubernetes_persistent_volume_claim" "opendj_config_volume_claim" {
  metadata {
    name = "opendj-config-volume-claim"
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    selector {
      match_labels = {
        opendj = "config"
      }
    }

    resources {
      requests = {
        storage = "100M"
      }
    }

    volume_name = "opendj-config"
  }
}

resource "kubernetes_persistent_volume_claim" "opendj_ldif_volume_claim" {
  metadata {
    name = "opendj-ldif-volume-claim"
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    selector {
      match_labels = {
        opendj = "ldif"
      }
    }

    resources {
      requests = {
        storage = "100M"
      }
    }

    volume_name = "opendj-ldif"
  }
}

resource "kubernetes_persistent_volume_claim" "opendj_logs_volume_claim" {
  metadata {
    name = "opendj-logs-volume-claim"
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    selector {
      match_labels = {
        opendj = "logs"
      }
    }

    resources {
      requests = {
        storage = "100M"
      }
    }

    volume_name = "opendj-logs"
  }
}

resource "kubernetes_persistent_volume_claim" "opendj_db_volume_claim" {
  metadata {
    name = "opendj-db-volume-claim"
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    selector {
      match_labels = {
        opendj = "db"
      }
    }

    resources {
      requests = {
        storage = "100M"
      }
    }

    volume_name = "opendj-db"
  }
}

resource "kubernetes_persistent_volume_claim" "opendj_flag_volume_claim" {
  metadata {
    name = "opendj-flag-volume-claim"
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    selector {
      match_labels = {
        opendj = "flag"
      }
    }

    resources {
      requests = {
        storage = "100M"
      }
    }

    volume_name = "opendj-flag"
  }
}


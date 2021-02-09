resource "kubernetes_deployment" "nfs_client_provisioner" {
  count = "${var.nfs_server_address == "none" ? 0 : 1}"
  metadata {
    name      = "nfs-client-provisioner"
    namespace = "default"

    labels = {
      app = "nfs-client-provisioner"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "nfs-client-provisioner"
      }
    }

    template {
      metadata {
        labels = {
          app = "nfs-client-provisioner"
        }
      }

      spec {
        volume {
          name = "nfs-client-root"

          nfs {
            server = var.nfs_server_address
            path   = "/data/dynamic"
          }
        }

        container {
          name  = "nfs-client-provisioner"
          image = "quay.io/external_storage/nfs-client-provisioner:latest"

          env {
            name  = "PROVISIONER_NAME"
            value = "nfs-storage"
          }

          env {
            name  = "NFS_SERVER"
            value = var.nfs_server_address
          }

          env {
            name  = "NFS_PATH"
            value = "/data/dynamic"
          }

          volume_mount {
            name       = "nfs-client-root"
            mount_path = "/persistentvolumes"
          }
        }

        automount_service_account_token = true
        service_account_name = "nfs-client-provisioner"
      }
    }

    strategy {
      type = "Recreate"
    }
  }
}

# resource "kubernetes_deployment" "ractest_client_provisioner" {
#   count = "${var.nfs_server_address == "none" ? 0 : 1}"
#   metadata {
#     name      = "ractest-client-provisioner"
#     namespace = "default"

#     labels = {
#       app = "ractest-client-provisioner"
#     }
#   }

#   spec {
#     replicas = 1

#     selector {
#       match_labels = {
#         app = "ractest-client-provisioner"
#       }
#     }

#     template {
#       metadata {
#         labels = {
#           app = "ractest-client-provisioner"
#         }
#       }

#       spec {
#         volume {
#           name = "ractest-client-root"

#           nfs {
#             server = var.nfs_server_address
#             path   = "/data/dynamic"
#           }
#         }

#         container {
#           name  = "ractest-client-provisioner"
#           image = "quay.io/external_storage/nfs-client-provisioner:latest"

#           env {
#             name  = "PROVISIONER_NAME"
#             value = "ractest-storage"
#           }

#           env {
#             name  = "NFS_SERVER"
#             value = var.nfs_server_address
#           }

#           env {
#             name  = "NFS_PATH"
#             value = "/data/dynamic"
#           }

#           volume_mount {
#             name       = "ractest-client-root"
#             mount_path = "/persistentvolumes"
#           }
#         }

#         automount_service_account_token = true
#         service_account_name = "nfs-client-provisioner"
#       }
#     }

#     strategy {
#       type = "Recreate"
#     }
#   }
# }

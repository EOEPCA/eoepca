resource "kubernetes_service_account" "nfs_client_provisioner" {
  metadata {
    name      = "nfs-client-provisioner"
    namespace = "default"
  }
}

resource "kubernetes_cluster_role" "nfs_client_provisioner_runner" {
  metadata {
    name = "nfs-client-provisioner-runner"
  }

  rule {
    verbs      = ["get", "list", "watch", "create", "delete"]
    api_groups = [""]
    resources  = ["persistentvolumes"]
  }

  rule {
    verbs      = ["get", "list", "watch", "update"]
    api_groups = [""]
    resources  = ["persistentvolumeclaims"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["storage.k8s.io"]
    resources  = ["storageclasses"]
  }

  rule {
    verbs      = ["create", "update", "patch"]
    api_groups = [""]
    resources  = ["events"]
  }
}

resource "kubernetes_cluster_role_binding" "run_nfs_client_provisioner" {
  metadata {
    name = "run-nfs-client-provisioner"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "nfs-client-provisioner"
    namespace = "default"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "nfs-client-provisioner-runner"
  }
}

resource "kubernetes_role" "leader_locking_nfs_client_provisioner" {
  metadata {
    name      = "leader-locking-nfs-client-provisioner"
    namespace = "default"
  }

  rule {
    verbs      = ["get", "list", "watch", "create", "update", "patch"]
    api_groups = [""]
    resources  = ["endpoints"]
  }
}

resource "kubernetes_role_binding" "leader_locking_nfs_client_provisioner" {
  metadata {
    name      = "leader-locking-nfs-client-provisioner"
    namespace = "default"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "nfs-client-provisioner"
    namespace = "default"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "leader-locking-nfs-client-provisioner"
  }
}


resource "kubernetes_namespace" "eo-user-compute" {
  metadata {
    annotations = {
      name = "eo-user-compute"
    }

    name = "eo-user-compute"
  }
}

resource "kubernetes_namespace" "eo-services" {
  metadata {
    annotations = {
      name = "eo-services"
    }

    name = "eo-services"
  }
}

resource "kubernetes_service_account" "bob-the-builder" {
  metadata {
    name = "bob-the-builder"
    namespace = "eo-services" 
  }
  
  automount_service_account_token = true  
}

resource "kubernetes_role" "eo-power-user" {
  metadata {
    namespace = "eo-services"
	name = "eo-power-user"
  }

  rule {
    api_groups     = ["", "extensions", "apps", "batch"]
    resources      = ["deployments", "replicasets", "pods", "jobs"]
    verbs          = ["get", "list", "watch", "create", "update", "patch", "delete"]
  }
}

resource "kubernetes_role_binding" "bob-the-builder-binding" {
  metadata {
    name      = "bob-the-builder-binding"
    namespace = "eo-services"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "eo-power-user"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "bob-the-builder"
    namespace = "eo-services"
  }
}

resource "kubernetes_role" "eo-power-user2" {
  metadata {
    namespace = "eo-user-compute"
	name = "eo-power-user2"
  }

  rule {
    api_groups     = ["batch"]
    resources      = ["jobs"]
    verbs          = ["get", "list", "watch", "create", "update", "patch", "delete"]
  }
}

resource "kubernetes_role_binding" "bob-the-builder-binding2" {
  metadata {
    name      = "bob-the-builder-binding2"
    namespace = "eo-user-compute"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "eo-power-user2"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "bob-the-builder"
    namespace = "eo-services"
  }
}

resource "kubernetes_cluster_role" "volume-reader" {
  metadata {
    name = "volume-reader"
  }

  rule {
    api_groups = [""]
    resources  = ["persistentvolumes"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_cluster_role_binding" "volume-reader" {
  metadata {
    name = "volume-reader"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "volume-reader"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "bob-the-builder"
    namespace = "eo-services"
  }
}




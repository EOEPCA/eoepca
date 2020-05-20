resource "kubernetes_role_binding" "gluu_rolebinding" {
  metadata {
    name      = "gluu-rolebinding"
    namespace = "default"
  }

  subject {
    kind = "User"
    name = "system:serviceaccount:default:default"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "gluu-role"
  }
}

resource "kubernetes_role" "gluu_role" {
  metadata {
    name      = "gluu-role"
    namespace = "default"
  }

  rule {
    verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
    api_groups = [""]
    resources  = ["configmaps", "secrets"]
  }
}


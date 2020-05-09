resource "kubernetes_network_policy" "opendj_np" {
  metadata {
    name = "opendj-np"
  }

  spec {
    pod_selector {
      match_labels = {
        app = "opendj"
      }
    }

    ingress {
      ports {
        protocol = "TCP"
        port     = "1636"
      }

      ports {
        protocol = "TCP"
        port     = "8989"
      }

      ports {
        protocol = "TCP"
        port     = "4444"
      }

      from {
        pod_selector {
          match_labels = {
            app = "opendj"
          }
        }
      }
    }

    ingress {
      ports {
        protocol = "TCP"
        port     = "1636"
      }

      from {
        pod_selector {
          match_labels = {
            app = "oxauth"
          }
        }
      }
    }

    ingress {
      ports {
        protocol = "TCP"
        port     = "1636"
      }

      from {
        pod_selector {
          match_labels = {
            app = "oxtrust"
          }
        }
      }
    }

    ingress {
      ports {
        protocol = "TCP"
        port     = "1636"
      }

      from {
        pod_selector {
          match_labels = {
            app = "cr-rotate"
          }
        }
      }
    }

    ingress {
      ports {
        protocol = "TCP"
        port     = "1636"
      }

      from {
        pod_selector {
          match_labels = {
            app = "key-rotation"
          }
        }
      }
    }

    ingress {
      ports {
        protocol = "TCP"
        port     = "1636"
      }

      from {
        pod_selector {
          match_labels = {
            app = "oxpassport"
          }
        }
      }
    }

    ingress {
      ports {
        protocol = "TCP"
        port     = "1636"
      }

      from {
        pod_selector {
          match_labels = {
            app = "ldapbrowser"
          }
        }
      }
    }

    ingress {
      ports {
        protocol = "TCP"
        port     = "1636"
      }

      from {
        pod_selector {
          match_labels = {
            app = "oxshibboleth"
          }
        }
      }
    }

    egress {
      ports {
        protocol = "TCP"
        port     = "1636"
      }

      ports {
        protocol = "TCP"
        port     = "4444"
      }

      ports {
        protocol = "TCP"
        port     = "8989"
      }

      to {
        pod_selector {
          match_labels = {
            app = "opendj"
          }
        }
      }
    }

    egress {
      ports {
        protocol = "TCP"
        port     = "443"
      }

      ports {
        protocol = "UDP"
        port     = "53"
      }

      to {
        ip_block {
          cidr = "0.0.0.0/0"
        }
      }
    }

    policy_types = ["Ingress", "Egress"]
  }
}


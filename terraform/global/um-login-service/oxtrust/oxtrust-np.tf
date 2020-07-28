## Enabled only on test

# resource "kubernetes_network_policy" "oxtrust_np" {
#   metadata {
#     name = "oxtrust-np"
#   }

#   spec {
#     pod_selector {
#       match_labels = {
#         app = "oxtrust"
#       }
#     }

#     ingress {
#       ports {
#         protocol = "TCP"
#         port     = "8080"
#       }

#       from {
#         ip_block {
#           cidr = "198.168.0.0/16"
#         }
#       }
#     }

#     ingress {
#       ports {
#         protocol = "TCP"
#         port     = "8080"
#       }

#       from {
#         pod_selector {
#           match_labels = {
#             app = "oxpassport"
#           }
#         }
#       }
#     }

#     ingress {
#       ports {
#         protocol = "TCP"
#         port     = "8080"
#       }

#       from {
#         pod_selector {
#           match_labels = {
#             app = "oxshibboleth"
#           }
#         }
#       }
#     }

#     ingress {
#       ports {
#         protocol = "TCP"
#         port     = "8080"
#       }

#       from {
#         pod_selector {
#           match_labels = {
#             app = "cr-rotate"
#           }
#         }
#       }
#     }

#     egress {
#       ports {
#         protocol = "TCP"
#         port     = "8080"
#       }

#       to {
#         pod_selector {
#           match_labels = {
#             app = "oxauth"
#           }
#         }
#       }
#     }

#     egress {
#       ports {
#         protocol = "TCP"
#         port     = "1636"
#       }

#       to {
#         pod_selector {
#           match_labels = {
#             app = "opendj"
#           }
#         }
#       }
#     }

#     egress {
#       ports {
#         protocol = "TCP"
#         port     = "443"
#       }

#       ports {
#         protocol = "UDP"
#         port     = "53"
#       }

#       to {
#         ip_block {
#           cidr = "0.0.0.0/0"
#         }
#       }
#     }

#     egress {
#       ports {
#         protocol = "TCP"
#         port     = "6379"
#       }

#       to {
#         ip_block {
#           cidr = "198.168.0.0/16"
#         }
#       }
#     }

#     policy_types = ["Ingress", "Egress"]
#   }
# }


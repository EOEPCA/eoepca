## ONLY ACTIVE ON TEST

# resource "kubernetes_network_policy" "oxauth_np" {
#   metadata {
#     name = "oxauth-np"
#   }

#   depends_on = [ null_resource.waitfor-module-depends ]

#   spec {
#     pod_selector {
#       match_labels = {
#         app = "oxauth"
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
#             app = "oxtrust"
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
#             app = "key-rotation"
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

#     egress {
#       ports {
#         protocol = "UDP"
#         port     = "53"
#       }

#       ports {
#         protocol = "TCP"
#         port     = "443"
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


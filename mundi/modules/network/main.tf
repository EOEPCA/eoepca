resource "opentelekomcloud_networking_router_v2" "k8s" {
  name                = "${var.cluster_name}-router"
  count               = var.use_neutron
  admin_state_up      = "true"
  external_gateway = var.external_net
  enable_snat = true
}

resource "opentelekomcloud_networking_network_v2" "k8s" {
  name           = var.network_name
  count          = var.use_neutron
  #dns_domain     = var.network_dns_domain != null ? var.network_dns_domain : null
  admin_state_up = "true"
}

resource "opentelekomcloud_networking_subnet_v2" "k8s" {
  name            = "${var.cluster_name}-internal-network"
  count           = var.use_neutron
  network_id      = opentelekomcloud_networking_network_v2.k8s[count.index].id
  cidr            = var.subnet_cidr
  ip_version      = 4
  dns_nameservers = var.dns_nameservers
}

resource "opentelekomcloud_networking_router_interface_v2" "k8s" {
  count     = var.use_neutron
  router_id = opentelekomcloud_networking_router_v2.k8s[count.index].id
  subnet_id = opentelekomcloud_networking_subnet_v2.k8s[count.index].id
}

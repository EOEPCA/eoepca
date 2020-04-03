resource "openstack_networking_network_v2" "eoepca" {
  name           = "eoepca"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "eoepca" {
  name            = "eoepca"
  network_id      = openstack_networking_network_v2.eoepca.id
  cidr            = "192.168.1.0/24"
  ip_version      = 4
  dns_nameservers = ["8.8.8.8", "8.8.4.4"]
}

data "openstack_networking_network_v2" "external_network" {
  name = var.external_network_name
}

resource "openstack_networking_router_v2" "eoepca" {
  name                = "eoepca"
  admin_state_up      = "true"
  external_network_id = data.openstack_networking_network_v2.external_network.id
}

resource "openstack_networking_router_interface_v2" "eoepca" {
  router_id = openstack_networking_router_v2.eoepca.id
  subnet_id = openstack_networking_subnet_v2.eoepca.id
}

resource "openstack_networking_floatingip_v2" "eoepca" {
  pool = var.pool
}

resource "openstack_compute_floatingip_associate_v2" "eoepca" {
  # Associates floating IP in the public network to the first master node
  floating_ip = openstack_networking_floatingip_v2.eoepca.address
  instance_id = openstack_compute_instance_v2.k8s_master[0].id
}

output "address" {
  value = openstack_networking_floatingip_v2.eoepca.address
}

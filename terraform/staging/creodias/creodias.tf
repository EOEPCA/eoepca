
resource "openstack_compute_keypair_v2" "eoepca" {
  name       = "eoepca"
  public_key = file(var.ssh_key_file)
}

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

data "openstack_networking_secgroup_v2" "allow_ping" {
    name = "allow_ping_ssh_rdp"
}

resource "openstack_compute_secgroup_v2" "eoepca" {
  name        = "eoepca"
  description = "Security group for the EOEPCA staging instances"
  rule {
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 80
    to_port     = 80
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = -1
    to_port     = -1
    ip_protocol = "icmp"
    cidr        = "0.0.0.0/0"
  }
}

resource "openstack_compute_instance_v2" "k8s_master" {
  name        = "k8s_master"
  image_name  = var.image
  flavor_name = var.flavor
  key_pair    = openstack_compute_keypair_v2.eoepca.name
  security_groups = [ "default", openstack_compute_secgroup_v2.eoepca.name, data.openstack_networking_secgroup_v2.allow_ping.name ]

  network {
    uuid = openstack_networking_network_v2.eoepca.id
  }

  /*provisioner "remote-exec" {
    connection {
      user        = var.ssh_user_name
      host        = "192.168.1.1" #data.openstack_networking_port_v2.default_port.fixed_ip
      private_key = var.ssh_key_file
    }

    inline = [
      "sudo apt-get -y update",
      "sudo apt-get -y install nginx",
      "sudo service nginx start"
    ]
  }*/
}

resource "openstack_networking_floatingip_v2" "eoepca" {
  pool = var.pool
}

resource "openstack_compute_floatingip_associate_v2" "eoepca" {
  floating_ip = openstack_networking_floatingip_v2.eoepca.address
  instance_id = openstack_compute_instance_v2.k8s_master.id
  fixed_ip    = openstack_compute_instance_v2.k8s_master.network.0.fixed_ip_v4
}

output "address" {
  value = openstack_networking_floatingip_v2.eoepca.fixed_ip
}

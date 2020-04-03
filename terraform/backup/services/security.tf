resource "openstack_compute_keypair_v2" "eoepca" {
  name       = "eoepca"
  public_key = file("${var.ssh_key_file}.pub") # This identity is stored unsecurely!!
}

data "openstack_networking_secgroup_v2" "default" {
  name = "default"
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

resource "openstack_compute_secgroup_v2" "kubernetes" {
  name        = "kubernetes"
  description = "Security group for the Kubernetes master EOEPCA instances"
  rule {
    from_port   = 6443
    to_port     = 6443
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }
}
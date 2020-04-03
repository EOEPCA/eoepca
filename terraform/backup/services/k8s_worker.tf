variable "worker_nodes" {
  default = 2
}

/* resource "openstack_networking_port_v2" "worker_ports" {
  count          = var.worker_nodes
  name           = format("worker_port-%02d", count.index + 1)
  network_id     = openstack_networking_network_v2.eoepca.id
  admin_state_up = "true"
  security_group_ids = [ data.openstack_networking_secgroup_v2.default.id, openstack_compute_secgroup_v2.eoepca.id ]
} */

resource "openstack_compute_instance_v2" "k8s_worker" {
  count = var.worker_nodes
  name = format("k8s_worker-%02d", count.index + 1)

  image_name  = var.image
  flavor_name = var.flavor
  key_pair    = openstack_compute_keypair_v2.eoepca.name

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

/* resource "openstack_compute_interface_attach_v2" "worker_attachments" {
  count       = var.worker_nodes
  instance_id = openstack_compute_instance_v2.k8s_worker.*.id[count.index]
  port_id     = openstack_networking_port_v2.worker_ports.*.id[count.index]
} */



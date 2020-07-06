resource "openstack_compute_instance_v2" "eoepca_nfs" {
  name       = "eoepca_nfs"
  image_name = "${var.image}"

  flavor_id       = "20"
  key_pair        = "kubernetes-eoepca"
  security_groups = ["default", "eoepca-k8s", "eoepca-bastion"]

  network {
    name = "${var.network_name}"
  }

  metadata = {
    kubespray_groups = "nfs"
    ssh_user         = "${var.ssh_user}"
    depends_on       = "${var.network_id}"
  }
}

resource "null_resource" "dummy_dependency" {
  triggers = {
    dependency_id = "${var.router_id}"
  }
}

resource "openstack_networking_floatingip_v2" "eoepca_nfs" {
  pool       = "${var.floatingip_pool}"
  depends_on = ["null_resource.dummy_dependency"]
}

resource "openstack_compute_floatingip_associate_v2" "eoepca_nfs" {
  instance_id           = "${openstack_compute_instance_v2.eoepca_nfs.id}"
  floating_ip           = "${openstack_networking_floatingip_v2.eoepca_nfs.address}"
  wait_until_associated = "${var.wait_for_floatingip}"

  provisioner "file" {
    source      = "${path.module}/nfs-setup.sh"
    destination = "/tmp/nfs-setup.sh"

    connection {
      type     = "ssh"
      user     = "eouser"
      private_key = "${chomp(file(trimsuffix(var.public_key_path, ".pub")))}"
      host     = "${openstack_networking_floatingip_v2.eoepca_nfs.address}"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/nfs-setup.sh",
      "sudo /tmp/nfs-setup.sh",
    ]
    connection {
      type     = "ssh"
      user     = "eouser"
      private_key = "${chomp(file(trimsuffix(var.public_key_path, ".pub")))}"
      host     = "${openstack_networking_floatingip_v2.eoepca_nfs.address}"
    }
  }
}

variable "image" {}

variable "network_id" {
  default = ""
}

variable "network_name" {}

variable "floatingip_pool" {}

variable "wait_for_floatingip" {}

variable "router_id" {
  default = ""
}

variable "ssh_user" {}

variable "public_key_path" {}

output "nfs_ip_address" {
  value = openstack_compute_instance_v2.eoepca_nfs.access_ip_v4
}

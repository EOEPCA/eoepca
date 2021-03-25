resource "openstack_compute_instance_v2" "eoepca_nfs" {
  name       = "${var.cluster_name}-nfs"
  image_name = "${var.image}"
  # flavor_id  = "${var.flavor_k8s_node}"
  flavor_id  = "20"
  key_pair   = "${openstack_compute_keypair_v2.k8s.name}"

  lifecycle {
     ignore_changes = [image_name]
  }

  network {
    name = "${var.network_name}"
  }

  security_groups = ["${openstack_networking_secgroup_v2.k8s.name}",
  ]

  metadata = {
    ssh_user         = "${var.ssh_user}"
    kubespray_groups = "nfs,no-floating"
    depends_on       = "${openstack_blockstorage_volume_v2.nfs_expansion.id}"
    use_access_ip    = "${var.use_access_ip}"
  }

  connection {
    type         = "ssh"
    user         = "${var.ssh_user}"
    private_key  = "${chomp(file(trimsuffix(var.public_key_path, ".pub")))}"
    host         = "${self.access_ip_v4}"
    bastion_host = var.bastion_fips[0]
  }

  provisioner "file" {
    source      = "${path.module}/nfs-setup.sh"
    destination = "/tmp/nfs-setup.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/nfs-setup.sh",
      "echo /tmp/nfs-setup.sh | at now + 2 minute",
    ]
  }
}

output "nfs_ip_address" {
  value = openstack_compute_instance_v2.eoepca_nfs.access_ip_v4
}


resource "openstack_blockstorage_volume_v2" "nfs_expansion" {
  name        = "${var.cluster_name}-nfs-expansion"
  description = "Extra space for eoepca nfs"
  size        = "${var.nfs_disk_size}"
  volume_type = "SSD"
  metadata = {
    attached_mode    = "rw"
    readonly         = "False"
    depends_on       = "${var.network_id}"
  }
}

resource "openstack_compute_volume_attach_v2" "volume_attachment_nfs" {
  instance_id = "${openstack_compute_instance_v2.eoepca_nfs.id}"
  volume_id   = "${openstack_blockstorage_volume_v2.nfs_expansion.id}"
  device = "/dev/sdb"


}
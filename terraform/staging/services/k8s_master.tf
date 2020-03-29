variable "master_nodes" {
  default = 1
}

resource "openstack_networking_port_v2" "master_port" {
  #count          = var.master_nodes
  #name           = format("master_port-%02d", count.index)
  name               = "master_port"
  network_id         = openstack_networking_network_v2.eoepca.id
  admin_state_up     = "true"
  security_group_ids = [data.openstack_networking_secgroup_v2.default.id, openstack_compute_secgroup_v2.eoepca.id]
}

resource "openstack_compute_instance_v2" "k8s_master" {
  count = var.master_nodes
  name  = format("k8s_master-%02d", count.index + 1)

  image_name  = var.image
  flavor_name = var.flavor
  key_pair    = openstack_compute_keypair_v2.eoepca.name

  security_groups = [data.openstack_networking_secgroup_v2.default.name,
    openstack_compute_secgroup_v2.eoepca.name,
    openstack_compute_secgroup_v2.kubernetes.name]
  network {
    uuid = openstack_networking_network_v2.eoepca.id
    #port = openstack_networking_port_v2.master_port.id
  }

  # Install Docker containers runtime
  /* provisioner "remote-exec" {
    connection {
      user        = var.ssh_user_name
      host        = openstack_networking_floatingip_v2.eoepca.address # openstack_networking_port_v2.master_port.fixed_ip.0.ip_address
      private_key = file(var.ssh_key_file)
    }

    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common gnupg2",
      "sudo sh -c 'curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -'",
      "sudo add-apt-repository \"deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\"",
      "sudo apt-get update",
      "sudo apt-get install -y containerd.io=1.2.13-1 docker-ce=5:19.03.8~3-0~ubuntu-$(lsb_release -cs) docker-ce-cli=5:19.03.8~3-0~ubuntu-$(lsb_release -cs)",
      "sudo touch /etc/docker/daemon.json",
      "sudo cat /etc/docker/daemon.json < '{'",
      "sudo cat /etc/docker/daemon.json < '\"exec-opts\": [\"native.cgroupdriver=systemd\"]'",
      "sudo cat /etc/docker/daemon.json < '\"log-driver\": \"json-file\"'",
      "sudo cat /etc/docker/daemon.json < '\"log-opts\": {'",
      "sudo cat /etc/docker/daemon.json < '\"max-size\": \"100m\"'",
      "sudo cat /etc/docker/daemon.json < '}'",
      "sudo cat /etc/docker/daemon.json < '\"storage-driver\": \"overlay2\"'",
      "sudo cat /etc/docker/daemon.json < '}'",
      "sudo mkdir -p /etc/systemd/system/docker.service.d",
      "sudo systemctl daemon-reload",
      "sudo systemctl restart docker"
    ]
  } */

  /*  provisioner "remote-exec" {
    connection {
      user        = var.ssh_user_name
      host        = openstack_networking_floatingip_v2.eoepca.address # openstack_networking_port_v2.master_port.fixed_ip.0.ip_address
      private_key = file(var.ssh_key_file)
    }

     inline = [
      "mkdir ~/.kube/",
      "kubectl config view --raw > ~/.kube/config"
    ] 
  } */
  depends_on = [openstack_networking_floatingip_v2.eoepca]
}

/*resource "openstack_compute_interface_attach_v2" "master_attachment" {
  #count       = var.master_nodes
  instance_id = openstack_compute_instance_v2.k8s_master[0].id
  port_id     = openstack_networking_port_v2.master_port.id
} */



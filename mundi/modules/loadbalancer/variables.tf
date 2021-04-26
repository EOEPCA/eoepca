variable "cluster_name" {}

variable "k8s_node_ips" {
  type = list
}

variable "network_id" {}

variable "floatingip_pool" {}

variable "k8s_secgroup_id" {}

variable "use_neutron" {}

variable "private_subnet_id" {}


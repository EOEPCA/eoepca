output "k8s_master_ips" {
  value = "${openstack_compute_instance_v2.k8s_master_no_floating_ip.*.access_ip_v4}"
}

output "k8s_node_ips" {
  value = "${openstack_compute_instance_v2.k8s_node_no_floating_ip.*.access_ip_v4}"
}

output "k8s_node_hm_ips" {
  value = "${openstack_compute_instance_v2.k8s_node_high_memory.*.access_ip_v4}"
}

output "k8s_secgroup_id" {
  value = "${openstack_networking_secgroup_v2.k8s.id}"
}

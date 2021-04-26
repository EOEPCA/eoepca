output "k8s_master_ips" {
  value = "${opentelekomcloud_compute_instance_v2.k8s_master_no_floating_ip_custom_volume_size.*.access_ip_v4}"
}

output "k8s_node_ips" {
  value = "${opentelekomcloud_compute_instance_v2.k8s_node_no_floating_ip_custom_volume_size.*.access_ip_v4}"
}

output "k8s_secgroup_id" {
  value = "${opentelekomcloud_networking_secgroup_v2.k8s.id}"
}

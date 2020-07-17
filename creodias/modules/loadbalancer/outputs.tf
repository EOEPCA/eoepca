
output "loadbalancer_fips" {
  value = "${openstack_networking_floatingip_v2.loadbalancer[*].address}"
}

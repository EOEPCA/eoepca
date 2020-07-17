
resource "openstack_networking_secgroup_v2" "lb" {
  name                 = "${var.cluster_name}-lb"
  description          = "${var.cluster_name} - LoadBalancer"
  delete_default_rules = true
}

resource "openstack_networking_secgroup_rule_v2" "egress_ipv4" {
  direction         = "egress"
  ethertype         = "IPv4"
  security_group_id = "${openstack_networking_secgroup_v2.lb.id}"
}

resource "openstack_networking_secgroup_rule_v2" "egress_ipv6" {
  direction         = "egress"
  ethertype         = "IPv6"
  security_group_id = "${openstack_networking_secgroup_v2.lb.id}"
}

resource "openstack_networking_secgroup_rule_v2" "ingress_ipv4" {
  direction         = "ingress"
  ethertype         = "IPv4"
  security_group_id = "${openstack_networking_secgroup_v2.lb.id}"
}

resource "openstack_networking_secgroup_rule_v2" "ingress_ipv6" {
  direction         = "ingress"
  ethertype         = "IPv6"
  security_group_id = "${openstack_networking_secgroup_v2.lb.id}"
}

resource "openstack_lb_loadbalancer_v2" "k8s" {
  name            = "${var.cluster_name}-lb"
  count     = var.use_neutron
  vip_network_id = var.network_id

  security_group_ids = [ openstack_networking_secgroup_v2.lb.id, var.k8s_secgroup_id ]

}

resource "openstack_lb_listener_v2" "https" {
  name = "https"
  count     = var.use_neutron
  protocol        = "HTTPS"
  protocol_port   = 443
  loadbalancer_id = openstack_lb_loadbalancer_v2.k8s[count.index].id

  # insert_headers = {
  #   X-Forwarded-For = "true"
  # }
}

resource "openstack_lb_listener_v2" "http" {
  name = "http"
  count     = var.use_neutron
  protocol        = "HTTP"
  protocol_port   = 80
  loadbalancer_id = openstack_lb_loadbalancer_v2.k8s[count.index].id

  # insert_headers = {
  #   X-Forwarded-For = "true"
  # }
}

resource "openstack_lb_pool_v2" "https" {
  name = "https"
  protocol    = "HTTPS"
  count     = var.use_neutron
  lb_method   = "ROUND_ROBIN"
  listener_id = openstack_lb_listener_v2.https[count.index].id

  persistence {
    type        = "SOURCE_IP"
  }
}

resource "openstack_lb_pool_v2" "http" {
  name = "http"
  protocol    = "HTTP"
  count     = var.use_neutron
  lb_method   = "ROUND_ROBIN"
  listener_id = openstack_lb_listener_v2.http[count.index].id

  persistence {
    type        = "SOURCE_IP"
  }
}

resource "openstack_lb_members_v2" "https" {
  count     = var.use_neutron
  pool_id       = openstack_lb_pool_v2.https[count.index].id

  dynamic "member" {
    for_each = var.k8s_node_ips
    content {
      address = member.value
      protocol_port = 31443
    }
  }
}

resource "openstack_lb_members_v2" "http" {
  count     = var.use_neutron
  pool_id       = openstack_lb_pool_v2.http[count.index].id

  dynamic "member" {
    for_each = var.k8s_node_ips
    content {
      address = member.value
      protocol_port = 31080
    }
  }
}

# # resource "openstack_lb_monitor_v2" "https_ping" {
# #   count     = var.use_neutron
# #   pool_id     = "${openstack_lb_pool_v2.https[count.index].id}"
# #   type        = "PING"
# #   delay       = 5
# #   timeout     = 5
# #   max_retries = 3
# #   max_retries_down = 3
# # }

# # resource "openstack_lb_monitor_v2" "http_ping" {
# #   count     = var.use_neutron
# #   pool_id     = "${openstack_lb_pool_v2.http[count.index].id}"
# #   type        = "PING"
# #   delay       = 5
# #   timeout     = 5
# #   max_retries = 3
# #   max_retries_down = 3
# # }

resource "openstack_networking_floatingip_v2" "loadbalancer" {
  count     = var.use_neutron
  pool       = var.floatingip_pool
  port_id = openstack_lb_loadbalancer_v2.k8s[count.index].vip_port_id
}

resource "openstack_networking_floatingip_associate_v2" "loadbalancer" {
  count     = var.use_neutron
  floating_ip = openstack_networking_floatingip_v2.loadbalancer[count.index].address
  port_id = openstack_lb_loadbalancer_v2.k8s[count.index].vip_port_id
}

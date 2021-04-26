
# resource "opentelekomcloud_networking_secgroup_v2" "lb" {
#   name                 = "${var.cluster_name}-lb"
#   description          = "${var.cluster_name} - LoadBalancer"
#   delete_default_rules = true
# }

# resource "opentelekomcloud_networking_secgroup_rule_v2" "egress_ipv4" {
#   direction         = "egress"
#   ethertype         = "IPv4"
#   security_group_id = "${opentelekomcloud_networking_secgroup_v2.lb.id}"
# }

# resource "opentelekomcloud_networking_secgroup_rule_v2" "egress_ipv6" {
#   direction         = "egress"
#   ethertype         = "IPv6"
#   security_group_id = "${opentelekomcloud_networking_secgroup_v2.lb.id}"
# }

# resource "opentelekomcloud_networking_secgroup_rule_v2" "ingress_https" {
#   direction         = "ingress"
#   ethertype         = "IPv4"
#   protocol = "tcp"
#   port_range_min    = 443
#   port_range_max    = 443
#   security_group_id = "${opentelekomcloud_networking_secgroup_v2.lb.id}"
# }

# resource "opentelekomcloud_networking_secgroup_rule_v2" "ingress_http" {
#   direction         = "ingress"
#   ethertype         = "IPv4"
#   protocol = "tcp"
#   port_range_min    = 80
#   port_range_max    = 80
#   security_group_id = "${opentelekomcloud_networking_secgroup_v2.lb.id}"
# }

# resource "opentelekomcloud_elb_loadbalancer" "k8s" {
#   name            = "${var.cluster_name}-lb"
#   count     = var.use_neutron
#   vpc_id = var.network_id
#   vip_subnet_id = var.private_subnet_id

#   type = "Internal"
#   admin_state_up = "true"

#   security_group_id = "${opentelekomcloud_networking_secgroup_v2.lb.id}"

# }

# resource "opentelekomcloud_elb_listener" "https" {
#   name = "https"
#   count     = var.use_neutron
#   protocol        = "HTTPS"
#   protocol_port   = 443
#   backend_protocol        = "HTTP"
#   lb_algorithm     = "roundrobin"
#   loadbalancer_id = opentelekomcloud_elb_loadbalancer.k8s[count.index].id
#   backend_port = 31443
#   # insert_headers = {
#   #   X-Forwarded-For = "true"
#   # }
# }

# resource "opentelekomcloud_elb_listener" "http" {
#   name = "http"
#   count     = var.use_neutron
#   protocol        = "HTTP"
#   backend_protocol        = "HTTP"
#   lb_algorithm     = "roundrobin"
#   protocol_port   = 80
#   loadbalancer_id = opentelekomcloud_elb_loadbalancer.k8s[count.index].id
#   backend_port = 31080

#   # insert_headers = {
#   #   X-Forwarded-For = "true"
#   # }
# }

# resource "opentelekomcloud_lb_pool_v2" "https" {
#   name = "https"
#   protocol    = "HTTP"
#   count     = var.use_neutron
#   lb_method   = "ROUND_ROBIN"
#   listener_id = opentelekomcloud_elb_listener.https[count.index].id

#   persistence {
#     type        = "SOURCE_IP"
#   }
# }

# resource "opentelekomcloud_lb_pool_v2" "http" {
#   name = "http"
#   protocol    = "HTTP"
#   count     = var.use_neutron
#   lb_method   = "ROUND_ROBIN"
#   listener_id = opentelekomcloud_elb_listener.http[count.index].id

#   persistence {
#     type        = "SOURCE_IP"
#   }
# }
# # resource "opentelekomcloud_elb_backend" "https" {
# #   count = var.use_neutron
# #   address     = var.k8s_node_ips[count.index]
# #   listener_id = opentelekomcloud_elb_listener.listener.id
# #   server_id   = "8f7a32f1-f66c-4d13-9b17-3a13f9f0bb8d"
# # }
# # resource "opentelekomcloud_lb_members_v2" "https" {
# #   count     = var.use_neutron
# #   pool_id       = opentelekomcloud_lb_pool_v2.https[count.index].id

# #   dynamic "member" {
# #     for_each = var.k8s_node_ips
# #     content {
# #       address = member.value
# #       protocol_port = 31443
# #     }
# #   }
# # }

# # resource "opentelekomcloud_lb_members_v2" "http" {
# #   count     = var.use_neutron
# #   pool_id       = opentelekomcloud_lb_pool_v2.http[count.index].id

# #   dynamic "member" {
# #     for_each = var.k8s_node_ips
# #     content {
# #       address = member.value
# #       protocol_port = 31080
# #     }
# #   }
# # }

# # resource "opentelekomcloud_lb_monitor_v2" "https_ping" {
# #   count     = var.use_neutron
# #   pool_id     = "${opentelekomcloud_lb_pool_v2.https[count.index].id}"
# #   type        = "PING"
# #   delay       = 5
# #   timeout     = 5
# #   max_retries = 3
# #   max_retries_down = 3
# # }

# # resource "opentelekomcloud_lb_monitor_v2" "http_ping" {
# #   count     = var.use_neutron
# #   pool_id     = "${opentelekomcloud_lb_pool_v2.http[count.index].id}"
# #   type        = "PING"
# #   delay       = 5
# #   timeout     = 5
# #   max_retries = 3
# #   max_retries_down = 3
# # }

# # resource "opentelekomcloud_networking_floatingip_v2" "loadbalancer" {
# #   count     = var.use_neutron
# #   pool       = var.floatingip_pool
# #   port_id = opentelekomcloud_elb_loadbalancer.k8s[count.index].vip_port_id
# # }

# # resource "opentelekomcloud_networking_floatingip_associate_v2" "loadbalancer" {
# #   count     = var.use_neutron
# #   floating_ip = opentelekomcloud_networking_floatingip_v2.loadbalancer[count.index].address
# #   port_id = opentelekomcloud_elb_loadbalancer.k8s[count.index].vip_port_id
# # }

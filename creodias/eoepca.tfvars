
# cluster
cluster_name = "testing"

# network
external_net = "31d7e67a-b30a-43f4-8b06-1667c70ba90d"
floatingip_pool = "external3"
network_name = "testing"
subnet_cidr = "192.168.123.0/24"
dns_nameservers = ["185.48.234.234", "185.48.234.238"]

#-------------------------------------------------------------------------------
# Floating IPs for VMs
#-------------------------------------------------------------------------------

# bastion - 0|1 bastion nodes
number_of_bastions = 1

# standalone etcds
number_of_etcd = 0

# masters
number_of_k8s_masters = 0
number_of_k8s_masters_no_etcd = 0
number_of_k8s_masters_no_floating_ip = 1
number_of_k8s_masters_no_floating_ip_no_etcd = 0

# nodes
number_of_k8s_nodes = 0
number_of_k8s_nodes_no_floating_ip = 2

#-------------------------------------------------------------------------------
# Compute
#-------------------------------------------------------------------------------

# SSH key to use for access to nodes
public_key_path = "~/.ssh/id_rsa.pub"
# user on the node (ex. core on Container Linux, ubuntu on Ubuntu, etc.)
ssh_user = "eouser"

# flavors
flavor_bastion = "14"  # eo1.xsmall
flavor_k8s_master = "20"  # eo2.large
flavor_k8s_node = "20"  # eo2.large

# OS image to use for bastion, masters, standalone etcd instances, and nodes
image = "Ubuntu 18.04 LTS"

# An array of CIDRs allowed to SSH to hosts
bastion_allowed_remote_ips = ["0.0.0.0/0"]

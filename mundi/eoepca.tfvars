
# cluster
cluster_name = "develop"

# network
external_net = "0a2228f2-7f8a-45f1-8e09-9039e1d09975"
floatingip_pool = "admin_external_net"
network_name = "develop"
eodata_network_name = "eodata"
subnet_cidr = "192.168.123.0/24"
dns_nameservers = ["8.8.8.8", "8.8.4.4"]

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
number_of_k8s_nodes_no_floating_ip = 3

#-------------------------------------------------------------------------------
# Compute
#-------------------------------------------------------------------------------

# SSH key to use for access to nodes
public_key_path = "~/.ssh/id_rsa.pub"
# user on the node (ex. core on Container Linux, ubuntu on Ubuntu, etc.)
ssh_user = "ubuntu"

# flavors
flavor_bastion = "s2.medium.1"  # eo1.xsmall
flavor_k8s_master = "s2.large.4"  # eo2.large
flavor_k8s_node = "s2.xlarge.4"  # eo2.xlarge

# OS image to use for bastion, masters, standalone etcd instances, and nodes
image = "Standard_Ubuntu_18.04_latest"

# An array of CIDRs allowed to SSH to hosts
bastion_allowed_remote_ips = ["0.0.0.0/0"]

# Size of nfs disk in GB
nfs_disk_size = 10

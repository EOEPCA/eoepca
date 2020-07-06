# your Kubernetes cluster name here
cluster_name = "eoepca-test"

# SSH key to use for access to nodes
public_key_path = "~/.ssh/id_rsa.pub"

# image to use for bastion, masters, standalone etcd instances, and nodes
image = "Ubuntu 18.04 LTS"

# user on the node (ex. core on Container Linux, ubuntu on Ubuntu, etc.)
ssh_user = "eouser"

# 0|1 bastion nodes
number_of_bastions = 1

flavor_bastion = "14"  # eo1.xsmall

# standalone etcds
number_of_etcd = 0
flavor_etcd = "20"

# masters
number_of_k8s_masters = 0

number_of_k8s_masters_no_etcd = 0

number_of_k8s_masters_no_floating_ip = 1

number_of_k8s_masters_no_floating_ip_no_etcd = 0

flavor_k8s_master = "18"  # eo1.large

# nodes
number_of_k8s_nodes = 0

number_of_k8s_nodes_no_floating_ip = 2

flavor_k8s_node = "18"  # eo1.large

# GlusterFS
# either 0 or more than one
#number_of_gfs_nodes_no_floating_ip = 0
#gfs_volume_size_in_gb = 150
# Container Linux does not support GlusterFS
image_gfs = "Ubuntu 18.04 LTS"
# May be different from other nodes
#ssh_user_gfs = "ubuntu"
#flavor_gfs_node = "18"

# networking
network_name = "eoepca-test-network"

external_net =  "31d7e67a-b30a-43f4-8b06-1667c70ba90d" # "5a0a9ccb-69e0-4ddc-9563-b8d6ae9ef06c"  #

subnet_cidr = "172.16.0.0/24"

floatingip_pool = "external3" #  "external2" # 

bastion_allowed_remote_ips = ["0.0.0.0/0"]

dns_nameservers = ["185.48.234.234", "185.48.234.238"]

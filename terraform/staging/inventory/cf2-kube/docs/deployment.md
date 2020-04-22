# Introduction

This guide describes how to install Kubernetes on CREODIAS OpenStack cloud, with support for adding/removing nodes, persistent volumes and load balancing.

This deployment method uses terraform and ansible playbooks from [the upstream kubespray project](https://github.com/kubernetes-sigs/kubespray) with prepared ansible configuration to enable required features.

# Pre-installation setup

## Getting code

Two repositories are cloned: upstream kubespray repository (for 2.12.0 release) and CloudFerro repository with ansible inventory pre-configured for CF2 cloud. The inventory is then symlinked into its expected location:

```
cloudferro-kubernetes code $ git clone --branch release-2.12 https://github.com/kubernetes-sigs/kubespray
cloudferro-kubernetes code $ git clone --branch v0.1 https://gitlab.cloudferro.com/kklimonda/cf2-kubespray kubespray/inventory/cf2-kube
```

## Terraform

Ansible inventory allows for a limited modification of the environment, such as setting a number of masters and workers, OpenStack flavors for specific instances, whether to allocate a floating IP for every instance, or use bastion host instead.

Those settings live in `inventory/cluster.tfvars` and should be self-explanatory.

## Ansible

Ansible inventory also allows for additional configuration of kubespray deployment. The provided inventory makes sure that deployed cluster can utilize load balancers and persistent storage as provided by OpenStack, but kubespray provides a vast number of configuration options to tweak the cluster to the specific workload.

Before using ansible, it has to be installed - that can be done in the virtualenv, to avoid installing packages system-wide:

```
cloudferro-kubernetes code $ python3.7 -m venv venv
cloudferro-kubernetes code $ source venv/bin/activate
(venv) cloudferro-kubernetes code $ pip install -r kubespray/requirements.txt
```

## OpenStack credentials

Kubespray-based OpenStack deployments require that the deployment host has access to OpenStack credentials - those credentials are used to configure kubernetes' integration with openstack services (for LBaaS and Block Storage integration).

Before the initial deployment, those credentials should be fetched from OpenStack and sourced in the terminal used for the deployment:

```
(venv) cloudferro-kubernetes code $ source openrc.sh
```

# Initial deployment

Once pre-installation setup is finished, the installation can begin. The installation process is divided into two phases: First, terraform is used to manage the underlying infrastructure (networks, VMs) and later kubespray's ansible playbooks are used to deploy the cluster.

## Terraform

Kubespray deployment assumes that terraform will be executed from the specific path, so change directory first, and then initialize terraform - this process fetches all terraform dependencies required by kubespray:

```
(venv) cloudferro-kubernetes code $ cd kubespray/inventory/cf2-kube
(venv) cloudferro-kubernetes cf2-kube $ terraform init contrib/terraform/openstack
Initializing modules...
- compute in ../../contrib/terraform/openstack/modules/compute
- ips in ../../contrib/terraform/openstack/modules/ips
- network in ../../contrib/terraform/openstack/modules/network

Initializing the backend...

Initializing provider plugins...
- Checking for available provider plugins...
- Downloading plugin for provider "openstack" (terraform-providers/openstack) 1.25.0...
- Downloading plugin for provider "null" (hashicorp/null) 2.1.2...

The following providers do not have any version constraints in configuration,
so the latest version was installed.

To prevent automatic upgrades to new major versions that may contain breaking
changes, it is recommended to add version = "..." constraints to the
corresponding provider blocks in configuration, with the constraint strings
suggested below.

* provider.null: version = "~> 2.1"

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
cloudferro-kubernetes cf2-kube $ 
```

Once terraform has been initialized, it can be then used to do the initial deployment:

```
(venv) cloudferro-kubernetes cf2-kube $ terraform apply -var-file=cluster.tfvars contrib/terraform/openstack
[...]
Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes[enter]
[...]
Apply complete! Resources: 21 added, 0 changed, 0 destroyed.

Outputs:

bastion_fips = [
  "[REDACTED]",
]
floating_network_id = 5a0a9ccb-69e0-4ddc-9563-b8d6ae9ef06c
k8s_master_fips = []
k8s_node_fips = []
private_subnet_id = 535ca2d0-1897-42c3-9cbe-23ed91a4d55b
router_id = [REDACTED]
```

## Ansible

After the initial terraform deployment is done, first subnet_id must be copied to ansible configuration - edit `inventory/cf2-kube/group_vars/all/openstack.yml`, uncomment `openstack_lbaas_subnet_id` and set it to the value of `private_subnet_id` as returned by terraform.

Then, execute kubespray's playbook to deploy the cluster:

```
(venv) cloudferro-kubernetes cf2-kube $ cd ../../
(venv) cloudferro-kubernetes kubespray $ ansible-playbook --become -i inventory/cf2-kube/hosts cluster.yml

PLAY [localhost] **********************************************************
[...]
PLAY RECAP ] **************************************************************
cf2-k8s-bastion-1          : ok=4    changed=1    unreachable=0    failed=0
cf2-k8s-k8s-master-nf-1    : ok=656  changed=145  unreachable=0    failed=0
cf2-k8s-k8s-node-nf-1      : ok=405  changed=87   unreachable=0    failed=0
cf2-k8s-k8s-node-nf-2      : ok=404  changed=87   unreachable=0    failed=0
localhost                  : ok=1    changed=0    unreachable=0    failed=0
[...]
(venv) cloudferro-kubernetes kubespray $
```

Once finished, two new folders should be created in the inventory directory: artifacts/ and credentials/.

credentials/ stores password for the initial kubernetes user (kube) that has to be used to authenticate to the cluster. artifacts/ contains kube config for the cluster.

IMPORTANT: with the default deployment, there is no external access to the Kubernetes API server - access is only available via the bastion host and so kubectl should be used on the bastion host, not on the host used for the deployment.

artifacts/admin.conf must be copied to .kube/config on the bastion host:

```
(venv) cloudferro-kubernetes kubespray $ ssh eouser@[bastion-ip] mkdir .kube/
(venv) cloudferro-kubernetes kubespray $ scp inventory/cf2-kube/artifacts/admin.conf .kube/config
```

download kubectl on the bastion host:

```
eouser@cf2-k8s-bastion-1:~$ curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
eouser@cf2-k8s-bastion-1:~$ chmod +x kubectl
eouser@cf2-k8s-bastion-1:~$ sudo mv kubectl /usr/local/bin/
```

Finally, `kubectl` can be used to interact with the cluster:

```
keouser@cf2-k8s-bastion-1:~$ kubectl get nodes
NAME                      STATUS   ROLES    AGE   VERSION
cf2-k8s-k8s-master-nf-1   Ready    master   14m   v1.16.3
cf2-k8s-k8s-node-nf-1     Ready    <none>   13m   v1.16.3
cf2-k8s-k8s-node-nf-2     Ready    <none>   13m   v1.16.3
```

# Cluster maintenance

## Adding nodes

In order to add new worker nodes to the cluster, first terraform's `cluster.tfvars` must be modified and the required variable changed. For example, to increase number of workers without floating ip, change variable `number_of_k8s_nodes_no_floating_ip`.

Afterwards, re-run terraform apply:

```
(venv) cloudferro-kubernetes cf2-kube $ terraform apply -var-file=cluster.tfvars contrib/terraform/openstack
module.compute.openstack_compute_keypair_v2.k8s: Refreshing state... [id=kubernetes-cf2-k8s]
[...]
An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # module.compute.openstack_compute_instance_v2.k8s_node_no_floating_ip[2] will be created
  + resource "openstack_compute_instance_v2" "k8s_node_no_floating_ip" {
[...]
Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
cloudferro-kubernetes cf2-kube $
```

and kubespray's scaling playbook:

```
(venv) cloudferro-kubernetes kubespray $ ansible-playbook --become -i inventory/cf2-kube/hosts scale.yml
```

Finally, a number of nodes can be verified directly in kubernetes, via kubectl:

```
eouser@cf2-k8s-bastion-1:~$ kubectl get nodes
NAME                      STATUS   ROLES    AGE   VERSION
cf2-k8s-k8s-master-nf-1   Ready    master   22m   v1.16.3
cf2-k8s-k8s-node-nf-1     Ready    <none>   21m   v1.16.3
cf2-k8s-k8s-node-nf-2     Ready    <none>   21m   v1.16.3
cf2-k8s-k8s-node-nf-3     Ready    <none>   39s   v1.16.3
eouser@cf2-k8s-bastion-1:~$
```


## Removing nodes

When removing nodes from the cluster it is important to remember that one can only remove nodes from the end of the list, and not random nodes in the cluster.

First, nodes must be drained - this process reschedules all pods from the affected nodes onto other nodes in the cluster ensuring that to be deleted nodes are no longer running any workloads:

```
eouser@cf2-k8s-bastion-1:~$ kubectl drain cf2-k8s-k8s-node-nf-3
node/cf2-k8s-k8s-node-nf-3 cordoned
node/cf2-k8s-k8s-node-nf-3 drained
eouser@cf2-k8s-bastion-1:~$
```

Next, run kubespray playbook for node removal:

```
(venv) cloudferro-kubernetes kubespray $ ansible-playbook --become -i inventory/cf2-kube/hosts remove-node.yml --extra-vars="node=cf2-k8s-k8s-node-nf-3"
```

It's important to pass `--extra-vars="node=cf2-k8s-k8s-node-nf-3"` with the name of the node that has been drained and scheduled for removal.

Finally, decrease terraform variable `number_of_k8s_nodes_no_floating_ip` and rerun terraform:

```
(venv) cloudferro-kubernetes cf2-kube $ terraform apply -var-file=cluster.tfvars contrib/terraform/openstack
module.compute.openstack_compute_keypair_v2.k8s: Refreshing state... [id=kubernetes-cf2-k8s]
[...]
An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  # module.compute.openstack_compute_instance_v2.k8s_node_no_floating_ip[2] will be destroyed
  - resource "openstack_compute_instance_v2" "k8s_node_no_floating_ip" {
[...]
Apply complete! Resources: 0 added, 0 changed, 1 destroyed.
(venv) cloudferro-kubernetes cf2-kube $
```

Again, kubectl can be used to verify that the node has been removed from the cluster:

```
eouser@cf2-k8s-bastion-1:~$ kubectl get nodes
NAME                      STATUS   ROLES    AGE   VERSION
cf2-k8s-k8s-master-nf-1   Ready    master   26m   v1.16.3
cf2-k8s-k8s-node-nf-1     Ready    <none>   25m   v1.16.3
cf2-k8s-k8s-node-nf-2     Ready    <none>   25m   v1.16.3
eouser@cf2-k8s-bastion-1:~$
```

# CREODIAS Setup

This directory contains the Terraform scripts that provision the VMs, security groups, network, load balancers etc. with the CREODIAS (Cloudferro/OpenStack) using the OpenStack terraform provider.

## Helper Scripts

These instructions reference some helper scripts, some of which rely upon the 'jq' tool ([command-line JSON processor](https://stedolan.github.io/jq/)). Therefore, to use these scripts it is necessary to ensure `jq` is installed on your local platform. It is available for installation via the package repositories for most popukar linux distrutions - see the [jq website](https://stedolan.github.io/jq/) for more details.

## Terraform

Terraform must be installed. See [terraform website](https://www.terraform.io/) for installation instructions.

Alternatively, use helper script [install-terraform.sh](../bin/install-terraform.sh)...
```
$ bin/install-terraform.sh
```

## OpenStack Client

The terraform OpenStack provider relies upon the OpenStack client that is installed as follows...

### Client Installation

```
$ pip install openstack client
```

### Client Configuration

There are various ways to configure the OpenStack client, but the easiest is via a `clouds.yaml` file - an example of which is provided in [example-clouds.yaml](./example-clouds.yaml).

```
clouds:
  eoepca:
    auth:
      auth_url: https://cf2.cloudferro.com:5000/v3
      username: "zzz@zzz.com"
      project_name: "eoepca"
      project_id: d86660d4a1a443579c71096771a8104c
      user_domain_name: "cloud_zzzzz"
      password: "zzzzzzzzzz"
    region_name: "RegionOne"
    interface: "public"
    identity_api_version: 3
```

The file must be configured with the details of your OpenStack project/environment and your credentials.

The clouds.yaml must be placed in one of the following locations:
* ./clouds.yaml (i.e. the current directory where terraform is invoked)
* $HOME/.config/openstack/clouds.yaml
* /etc/openstack/clouds.yaml

## Deployment Configuration

Before initiating deployment, the file [creodias/eoepca.tfvars](./eoepca.tfvars) should be tailored to fit the specific needs of your target environment.

## Initiate Deployment

The deployment is made from the `creodias` directory. The OpenStack cloud must be identified via the OS_CLOUD environemnt variable (for the benefit of the OpenStack provider used by terraform).

```
$ cd creodias
$ export OS_CLOUD=eoepca  # put your chosen project name here (ref. clouds.yaml)
$ terraform init
$ terraform apply -var-file=eoepca.tfvars  # enter 'yes' to apply
```

The successful terraform completion outpts various details (IP addresses, etc.) pertaining to the created infrastructure. These outputs are used as inputs to subsequent deployment steps.

The outputs can be obtained programmatically via the `terraform output` command. For example...
```
$ terraform output -json
```

## Deployment Topology

The terraform deployment creates the following:
* Virtual Machines:
  * Bastion host (Floating IP)<br>
    Single point of admin access (SSH) to the cluster
  * Master host<br>
    VM for Kubernetes control plane
  * Worker hosts<br>
    VMs for Kubernetes worker nodes (2 by default)
  * NFS server<br>
    Shared persistence service for the k8s cluster
* Network
  * Internal Network<br>
    Dedicated to the k8s cluster, with routing to/from external network
  * Load Balancer (Floating IP)<br>
    Provides the public http(s) access to the deployed platform<br>
    Forwards ports to k8s ingress controller NodePort: 80->31080, 443->31443
* Security Groups<br>
  Various groups to secure access to/from the internal network
* Floating IPs<br>
  For the bastion and the load balancer

## Access via Bastion host

For administration the deployment VMs must be accessed through the bastion host (via its public floating IP). The default deployment installs the public key of the user as an authorized key in each VM to facilitate this.

A single ssh session to a node can be established with, for example...
```
$ ssh -J eouser@185.52.192.69 eouser@192.168.123.10
```
...where 185.52.192.69 is the bastion floating ip, and 192.168.123.10 is the node ip

Alternatively, the ssh connection to the bastion can be used to establish a VPN from your local platform to the cluster using [sshuttle](https://sshuttle.readthedocs.io/en/stable/), for example...
```
sshuttle -r eouser@185.52.192.69 192.168.123.0/24
```

This is most easily invoked using our helper script [bastion-vpn.sh](../bin/bastion-vpn.sh) that uses the terraform output to construct the proper connection parameters...
```
$ ../bin/bastion-vpn.sh
```
NOTE that this can be run in the background with the `-D` (daemon) option. In this case use `killall sshuttle` to stop the VPN.

The use of the sshuttle VPN approach facilitates the use of kubectl for kubernetes cluster interactions - and so is strongly preferred.

[sshuttle](https://sshuttle.readthedocs.io/en/stable/) can be installed as follows...
```
pip install sshuttle
```

## Next Steps

Once the infrastructure is provisioned, the next step is to proceed with the setup of the [Kubernetes cluster](../kubernetes/README.md).

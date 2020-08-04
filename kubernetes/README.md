# Kubernetes Setup

This directory contains files to install Kubernetes onto the prepared infrastructure (VMs, network, load balancer, etc), as described in [CREODIAS Setup](../creodias/README.md).

Rancher [Kubernetes Engine (RKE)](https://rancher.com/products/rke/) is used to setup the cluster.

RKE is chosen as it provides a **simple** and **clean** k8s deployment:
* Simple - requiring only that docker is installed on each target node, and configured via a simple YAML configuration file
* Clean - the k8s cluster can setup (`rke up`) and torn-down (`rke down`) with simple commands that leave no trace

The infrastructure setup ([CREODIAS Setup](../creodias/README.md)) ensures that docker is installed on all target VMs - ready for installation of RKE.

## Helper Scripts

These instructions reference some helper scripts, some of which rely upon the 'jq' tool ([command-line JSON processor](https://stedolan.github.io/jq/)). Therefore, to use these scripts it is necessary to ensure `jq` is installed on your local platform. It is available for installation via the package repositories for most popukar linux distrutions - see the [jq website](https://stedolan.github.io/jq/) for more details.

## RKE Installation

RKE must be installed. See [Rancher website](https://rancher.com/products/rke/) for installation instructions.

Alternatively, use helper script [install-rke.sh](../bin/install-rke.sh)...
```
$ bin/install-rke.sh
```

## RKE Configuration

RKE is configured via the file `cluster.yml` that identifies the nodes and their roles within the k8s cluster.

The helper script [create-cluster-config.sh](create-cluster-config.sh) automatically creates this configuration based upon the terraform outputs from the infrastructure creation, including:
* configuration of master nodes
* configuration of worker nodes
* inclusion of 'ingress-nginx' controller<br>
  *Note that we are overriding the default nginx controller included with RKE in order to apply specific NodePort configuration*
* configuration of connection via bastion

```
$ cd kubernetes
$ create-cluster-config.sh
```

## Create Kubernetes Cluster

Once the configuration is in place then the cluster creation can be initiated...

```
$ rke up
```

## Install kubectl

For k8s cluster adminstration the kubectl command must be installed. See [Kubernetes website](https://kubernetes.io/docs/tasks/tools/install-kubectl/) for installation instructions.

Alternatively, use helper script [install-kubectl.sh](../bin/install-kubectl.sh)...
```
$ ../bin/install-kubectl.sh
```

## kubectl configuration

Following successful cluster setup, RKE outputs the 'kube config' as file `kube_config_cluster.yml` - to be used for interactions with the Kubernetes API, for example via the `kubectl` tool.

The configuration file can be used directly...
```
kubectl --kubeconfig=kube_config_cluster.yml <args>
```

Alternatively the file can be copied to $HOME/.kube/config to establish it as the default kubeconfig for kubectl...
```
$ cp kube_config_cluster.yml ~/.kube/config
```

NOTE that, in order to use kubectl from your local platform, it is necessary to establish a VPN to the bastion, as described in the [following section](#access-via-bastion-host). NOTE that this was not necessary during the `rke up` step due to the fact that RKE supports use of a bastion jump host via its configuration.

## Access via Bastion host

For administration the deployment VMs must be accessed through the bastion host (via its public floating IP). The default deployment installs the public key of the user as an authorized key in each VM to facilitate this. Further information [here](../creodias/README.md#access_via_bastion_host).

The ssh connection to the bastion can be used to establish a VPN from your local platform to the cluster using [sshuttle](https://sshuttle.readthedocs.io/en/stable/), for example...
```
sshuttle -r eouser@185.52.192.69 192.168.123.0/24
```

This is most easily invoked using our helper script [bastion-vpn.sh](../bin/bastion-vpn.sh) that uses the terraform output to construct the proper connection parameters...
```
$ ../bin/bastion-vpn.sh
```
NOTE that this can be run in the background with the `-D` (daemon) option. In this case use `killall sshuttle` to stop the VPN.

The use of the sshuttle VPN approach facilitates the use of kubectl for kubernetes cluster interactions.

[sshuttle](https://sshuttle.readthedocs.io/en/stable/) can be installed as follows...
```
pip install sshuttle
```

## Check k8s Cluster status

Once the VPN to the bastion is established, then the status of the cluster can be checked using kubectl...

```
$ kubectl get all -A
```

## Next Steps

Once the Kubernetes cluster is provisioned, the next step is to proceed with the deployment of the [EOEPCA system](../terraform/test/README.md).

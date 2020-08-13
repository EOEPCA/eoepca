# Minikube Setup

This directory contains files to create a local [Kubernetes](https://kubernetes.io/) cluster using [minikube](https://minikube.sigs.k8s.io/).

The local minikube cluster facilitates the local deployment (for development/testing purposes) of the EOEPCA system and/or individual building blocks.

## Install kubectl

For k8s cluster adminstration the kubectl command must be installed. See [Kubernetes website](https://kubernetes.io/docs/tasks/tools/install-kubectl/) for installation instructions.

Alternatively, use helper script [install-kubectl.sh](../bin/install-kubectl.sh)...
```
$ bin/install-kubectl.sh
```

## Install minikube

Minikube can be installed by following the instructions on the [Minikube website](https://minikube.sigs.k8s.io).

Alternatively, use helper script [setup-minikube.sh](./setup-minikube.sh) to download and install Minikube...
```
$ minikube/setup-minikube.sh
```

NOTE for running minikube in a VM...<br>
The setup-minikube.sh script retains the default (preferred) deployment of minikube as a docker container. This is not ideal if running minikube inside a VM. In this case it is better to run minikube natively inside VM using the 'none' driver, rather than the 'docker' driver. This can be achieved by running the script as follows...
```
$ minikube/setup-minikube.sh native
```

Or, see below for the [alternative approach using k3s](#install-k3s-alternative-to-minikube) instead of minikube. k3s has the advantage that its installation/setup runs more quickly than minikube, and is more lightweight for constrained execution environments, such as within a VM. In addition, it is provided by Rancher and is thus sibling to the Rancher Kubernetes Engine (RKE)) that is used for the main cloud deployment.

## Install k3s (alternative to minikube)

[k3s](https://k3s.io/) can be used as an alternative to minikube. k3s has the advantage that its installation/setup runs more quickly than minikube, and is more lightweight for constrained execution environments, such as within a VM.

In addition, k3s is provided by [Rancher](https://rancher.com/) and is thus sibling to the [Rancher Kubernetes Engine (RKE)](https://rancher.com/products/rke/) that is used for the main cloud deployment.

```
$ minikube/setup-k3s.sh
```

NOTE: The setup-k3s.sh script selects the 'docker' container runtime, as an alternative to the k3s default of 'containerd'. This is a requirements of the Argo component of the ADES building block.

## Next Steps

Once the Kubernetes cluster is provisioned, the next step is to proceed with the deployment of the [EOEPCA system](../terraform/test/README.md).

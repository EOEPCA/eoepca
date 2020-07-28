# Minikube Setup

This directory contains files to create a local [Kubernetes](https://kubernetes.io/) cluster using [minikube](https://minikube.sigs.k8s.io/).

The local minikube cluster facilitates the local deployment (for development/testing purposes) of the EOEPCA system and/or individual building blocks.

## Install kubectl

For k8s cluster adminstration the kubectl command must be installed. See [Kubernetes website](https://kubernetes.io/docs/tasks/tools/install-kubectl/) for installation instructions.

Alternatively, use helper script [install-kubectl.sh](../bin/install-kubectl.sh)...
```
$ ../bin/install-kubectl.sh
```

## Install minikube

Minikube can be installed by following the instructions on the [Minikube website](https://minikube.sigs.k8s.io).

Alternatively, use helper script [setup-minikube.sh](./setup-minikube.sh) to download and install Minikube...
```
$ ./setup-minikube.sh
```

## Next Steps

Once the Kubernetes cluster is provisioned, the next step is to proceed with the deployment of the [EOEPCA system](../terraform/test/README.md).

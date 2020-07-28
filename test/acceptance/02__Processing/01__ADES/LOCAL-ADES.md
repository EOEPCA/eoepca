# Setup local Kubernetes (microk8s) with ADES deployment

## Setup local Kubernetes cluster

Argo relies upon a Kubernetes cluster that uses `docker` as the container runtime. Therefore be careful to confirm this is the case, as common kubernetes distributions are are known to use alternatives, such as `containerd`.

This description establishes a local k8s cluster using `minikube`, which uses `docker` as the container runtime by default - noting that other runtimes can be selected with minikube (containerd, crio), https://minikube.sigs.k8s.io/docs/handbook/config/#runtime-configuration.

### Install kubectl

```
./test/bin/setup-kubectl.sh

```

### Install minikube

```
./test/bin/setup-minikube.sh

```

### Post Checks

```
kubectl version
kubectl get all
kubectl get all -A
```

## Deploy ADES

Navigate to this ADES directory...

```
cd eoepca/test/acceptance/Processing/ADES
```

The ADES is deployed to k8s via the script `ades-k8s.sh`. Before execution the WebDAV credentials (webdav_user/password) must be set in the file to be consistent with the WebDAV URL provided in `proc-ades/argo.json`.

The file `argo.json` is baked into the container image `eoepca/proc-ades:localkube`. If this needs to be edited then the image can be rebuilt and pushed to docker hub under a tag of your choosing. If the image tag is different from `eoepca/proc-ades:localkube` then the file `k8s/ades.yml` must be edited to reflect the required ADES container image.

### Deploy the ADES to k8s...

```
./ades-k8s.sh
```

### Check the ADES service is running...

```
kubectl get svc
```

From the output note the NodePort on which the `ades` service is running (high numbered port). This port number will be needed to access ADES service from localhost.

### Connect to the Argo Dashboard

Forward port from localhost to argo service

```
kubectl -n argo port-forward deployment/argo-server 2746:2746
```

Open browser at the URL http://localhost:2746/.

## Run some ADES commands

In the following commands the NodePort of the ades service must be used as \<node-port>.

### Deploy an application...

```
./dev-scripts/deploy.sh localhost:<node-port>
```

### Execute an application...

```
./dev-scripts/execute.sh localhost:<node-port>
```

### Get jobs for application...

```
./dev-scripts/get-jobs.sh localhost:<node-port>
```

### Get status for specific jobs...

\<job-id> can be read from output of previous command.

```
./dev-scripts/job-status.sh <job-id> localhost:<node-port>
```

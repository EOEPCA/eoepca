# Setup local Kubernetes (microk8s) with ADES deployment

## Setup microk8s

Assumes running on ubuntu.

### Ensure snap is installed...

```
sudo apt install snapd
```

### Add current user to the group...

```
sudo usermod -a -G microk8s $USER
```
*Probably have to logout/in to take effect.*

### Enable microk8s core extensions...

```
microk8s enable dns ingress
```

### Configure kubectl with the microk8s config...

```
microk8s config >$HOME/.kube/config
```

### Post Checks

```
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

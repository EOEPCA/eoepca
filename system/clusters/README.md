# EOEPCA GitOps Deployment

For development, the EOEPCA system is deployed to a target Kubernetes cluster with a GitOps approach using Flux Continuous Delivery (https://fluxcd.io/).

NOTE that, as an alternative approach, the [Deployment Guide](https://deployment-guide.docs.eoepca.org/) provides a more detailed description of the deployment and configuration of the components, supported by some shell scripts that deploy the components directly using `helm` (rather than using `flux` GitOps). The Deployment Guide represents a more informative introduction, and the supporting scripts assume `minikube` out-of-the-box.

## Deploy EOEPCA System

### Install Flux

The following command installs flux to `/usr/local/bin/flux`.

```
curl -s https://toolkit.fluxcd.io/install.sh | sudo bash
```

### KUBECONFIG Note

The 'flux' commands relies upon the `KUBECONFIG` environment variable - defaulting to `~/.kube/config` if it is not set. However, it seems that it does not support a `KUBECONFIG` expressed as a path (which is supported by `kubectl`). **This should be taken into account when executing flux commands.**

NOTE that the EOEPCA deploy/undeploy scripts take account of this automatically.

### Flux prerequisites

The flux pre-requisites can be checked...

```
flux check --pre
```

### GitHub credentials

GitHub is assumed for these instructions, but other git repos can be used - as described here https://toolkit.fluxcd.io/guides/installation/#generic-git-server.

The following environment variables must be set when initialising Flux in the following step...
```
export GITHUB_USER=<your-username>
export GITHUB_TOKEN=<your-token>
```

GITHUB_TOKEN is a Personal Access Token - as described here https://docs.github.com/en/free-pro-team@latest/github/authenticating-to-github/creating-a-personal-access-token.

When creating the token, all 'repo' scopes should be selected.

### Prepare the deployment TARGET

The EOEPCA team 'develop' cluster is deployed to CREODIAS and configured under path `./system/clusters/develop`. Before deployment, this confiuration must be tailored to your deployment environment. In particualr the Public IP of the target cluster must be applied within the configuration - achieved by searching for the terms `185.52.193.87` and `185.52.193.87.nip.io` in the configuration (all files under system/clusters/develop) and adjusting according to your environment.

Rather than edit 'develop' directly, you may consider making a copy of 'develop' to represent your cluster.

### Initialise the EOEPCA Deployment in Flux

The following scripts bootstraps Flux in the Kubernetes cluster, configured to synchronise to the EOEPCA/eoepca repository for its deployment specification.

```
./system/clusters/deployCluster.sh
```

The script is configured by the following environment variables:
* BRANCH<br>
  The branch of eoepca repository to use.<br>
  *Defaults to the current working branch.*
* TARGET<br>
  The deployment to target which is represented by the root directory `system/clusters/$TARGET` within the EOEPCA/eoepca repository.<br>
  *Defaults to 'minikube'.*

NOTE. Script deployCluster.sh is configured for deployment using the EOEPCA GitHub organisation. This must be adapted for your environment and git repository. For example, using a personal GitHub account the following command is more appropriate to perform the `flux bootstrap`...
```
flux bootstrap github \
  --owner=$GITHUB_USER \
  --repository=eoepca \
  --branch="${BRANCH}" \
  --path="system/clusters/${TARGET}/system" \
  --personal
```

NOTE. For deployment of additional clusters it is essential to make a copy of the `system/clusters/${TARGET}` directory, to ensure that the cluster deployment configuration that flux maintains in GitHub is kept independent for each cluster.

## GitOps Synchronisation

The flux deployment specification in system/clusters/$TARGET is expressed through `GitRepository` and `HelmRelease` resources.

Flux will monitor the charts referenced in the Helm Releases, and reconcile the state of the cluster in accordance with any changes to these components.

It should be noted that, when using a GitRepository as source, the referenced HelmRelease must increment their chart version number in order for flux to recognize the update.

## Undeploy Flux

The following script uninstalls the Flux CD kubernetes resources from the cluster...
```
./system/clusters/undeployCluster.sh
```

NOTE. This does **not** uninstall the eoepca components installed by flux.

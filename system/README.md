# EOEPCA GitOps Deployment

For development, the EOEPCA system is deployed to a target Kubernetes cluster with a GitOps approach using Flux Continuous Delivery (https://fluxcd.io/).

## Deploy EOEPCA System

### Install Flux

The following command installs flux to `/usr/local/bin/flux`.

```
curl -s https://toolkit.fluxcd.io/install.sh | sudo bash
```

### KUBECONFIG Note

The 'flux' commands relies upon the `KUBECONFIG` environment variable - defaulting to `~/.kube/config` is it is not set. However, it seems that it does not support a `KUBECONFIG` expressed as a path (which is supported by `kubectl`). **This should be taken into account when executing flux commands.**

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

### Initialise the EOEPCA Deployment in Flux

The following scripts bootstraps Flux in the Kubernetes cluster, configured to synchronise to the EOEPCA/eoepca repository for its deployment specification.

```
./system/deployEOEPCA.sh
```

The script is configured by the following environment variables:
* BRANCH<br>
  The branch of EOEPCA/eoepca repository to use.<br>
  *Defaults to the current working branch.*
* TARGET<br>
  The deployment to target which is represented by the root directory `system/$TARGET` within the EOEPCA/eoepca repository.<br>
  *Defaults to 'minikube'.*

## GitOps Synchronisation

The flux deployment specification in system/$TARGET is expressed through `GitRepository` and `HelmRelease` resources.

Flux will monitor the charts referenced in the Helm Releases, and reconcile the state of the cluster in accordance with any changes to these components.

It should be noted that, when using a GitRepository as source, the referenced HelmRelease must increment their chart version number in order for flux to recognize the update.

## Undeploy EOEPCA

The EOEPCA system deployment can be uninstalled by running the script...
```
./system/undeployEOEPCA.sh
```
...which uninstalls flux and hence the EOEPCA system components.

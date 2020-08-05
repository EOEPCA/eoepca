# EOEPCA System Deployment

This directory contains files to deploy the EOEPCA system onto the Kubernetes cluster, as described in [Kubernetes Setup](../../kubernetes/README.md).

## Helper Scripts

These instructions reference some helper scripts, some of which rely upon the 'jq' tool ([command-line JSON processor](https://stedolan.github.io/jq/)). Therefore, to use these scripts it is necessary to ensure `jq` is installed on your local platform. It is available for installation via the package repositories for most popukar linux distrutions - see the [jq website](https://stedolan.github.io/jq/) for more details.

## Terraform

Terraform must be installed (may already be been installed if [CREODIAS Setup](../../creodias/README.md#terraform) was followed). See [terraform website](https://www.terraform.io/) for installation instructions.

Alternatively, use helper script [install-terraform.sh](../bin/install-terraform.sh)...
```
$ ../bin/install-terraform.sh
```

## Deployment Configuration

The deployment is initiated via script [deployEOEPCA.sh](deployEOEPCA.sh).

The script is configured through the following environment variables, that can be set either by editing the script directly, or exporting them before running [deployEOEPCA.sh](deployEOEPCA.sh):
* `DOCKER_EMAIL`: Email of the account with access to the Dockerhub EOEPCA repository
* `DOCKER_USERNAME`: User name of the account with access to the Dockerhub EOEPCA repository
* `DOCKER_PASSWORD`: Password of the account with access to the Dockerhub EOEPCA repository
* `WSPACE_USERNAME`: User name of the account with access to the workspace. Defaults to 'eoepca' if not set
* `WSPACE_PASSWORD`: Password of the workspace account. Defaults to 'telespazio' if not set<br>
  *NOTE that the Workspace component is a stub (using [Nextcloud](https://nextcloud.com/)) that is instantiated within the cluster to support the stage-out of the ADES component using WebDAV. Hence, the credentials used are not important.*

There are some additional environment variables whose value is automatically deduced by the script (e.g. using `terraform output`). There should be no need to set these, but they can be overridden if required:
* `PUBLIC_IP`: Public IP address through which the system is accessed. Typically the floating IP address of the cloud Load Balancer
* `NFS_SERVER_ADDRESS`: Internal IP address through which the cluster's NFS server is accessed from the k8s nodes

## Initiate Deployment

The deployment uses the Terraform Kubernetes provider, that relies upon a working kubectl connection to the k8s cluster. Thus it is necessary to ensure that [Access via Bastion host](../../kubernetes/README.md#access-via-bastion-host) is established.

Once the appropriate environment variables are configured, then the script is executed to initiate deployment...
```
$ ./deployEOEPCA.sh
```

The deployment takes some time (approx. 20mins depending on target platforms), but should eventually conclude with a successful terraform deployment message.

## EOEPCA End-points

The EOEPCA system is exposed through a single public IP with the following endpoints:
* Login Server (Gluu) = https://test.${PUBLIC_IP}.nip.io
* ADES = http://ades.test.${PUBLIC_IP}.nip.io<br>
  *The ADES is a pure web service, and has no visual web interface*
* Workspace = http://workspace.test.${PUBLIC_IP}.nip.io

The helper script [open-endpoint.sh](../../bin/open-endpoint.sh) can be used to open these endpoints using the correct IP address...
```
$ ../../bin/open-endpoint.sh
```

## Next Steps

Once the EOEPCA system is deployed, the next step is to proceed with the [Acceptance Test execution](../../test/acceptance/README.md).

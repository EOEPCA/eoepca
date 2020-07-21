#!/usr/bin/env bash

# fail fast settings from https://dougrichardson.org/2018/08/03/fail-fast-bash-scripting.html
# set -euov pipefail
# Not supported in travis (xenial)
# shopt -s inherit_errexit

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

trap "cd '${ORIG_DIR}'" EXIT

ACTION=$1
if [ -z "$ACTION" ]; then ACTION="apply"; fi

AUTO_APPROVE=
if [ "$ACTION" = "apply" ]; then AUTO_APPROVE="--auto-approve"; fi

# Scrape VM infrastructure topology from terraform outputs
if hash terraform
then
  DEPLOYMENT_PUBLIC_IP="$(terraform output -state=../../creodias/terraform.tfstate -json | jq -r '.loadbalancer_fips.value[]')"
  DEPLOYMENT_NFS_SERVER="$(terraform output -state=../../creodias/terraform.tfstate -json | jq -r '.nfs_ip_address.value')"
fi

# Note minikube ip in case we need it
if hash minikube 2>/dev/null; then MINIKUBE_IP=$(minikube ip); fi

# Check presence of environment variables
#
# If not supplied, try to derive IPs from Terraform (cloud infrastructure (preferred)), followed by minikube
PUBLIC_IP="${PUBLIC_IP:-${DEPLOYMENT_PUBLIC_IP:-${MINIKUBE_IP:-none}}}"
NFS_SERVER_ADDRESS="${NFS_SERVER_ADDRESS:-${DEPLOYMENT_NFS_SERVER:-${MINIKUBE_IP:-none}}}"
#
# Other details...
DOCKER_EMAIL="${DOCKER_EMAIL:-none@eoepca.systemteam@telespazio.com}"
DOCKER_USERNAME="${DOCKER_USERNAME:-eoepcaci}"
DOCKER_PASSWORD="${DOCKER_PASSWORD:-eoepcaBu1ld3r}"
WSPACE_USERNAME="${WSPACE_USERNAME:-eoepca}"
WSPACE_PASSWORD="${WSPACE_PASSWORD:-telespazio}"
echo "Using PUBLIC_IP=${PUBLIC_IP}"
echo "Using NFS_SERVER_ADDRESS=${NFS_SERVER_ADDRESS}"

# Terraform plugins...
#
# kubectl plugin
KUBECTL_PLUGIN="terraform-provider-kubectl"
if [ ! -x "$KUBECTL_PLUGIN" ]
then
  echo Installing $KUBECTL_PLUGIN
  curl -Ls https://api.github.com/repos/gavinbunney/terraform-provider-kubectl/releases/latest \
    | jq -r '.assets[] | .browser_download_url | select(contains("linux-amd64"))' \
    | xargs -n 1 curl -Lo "$KUBECTL_PLUGIN"
  chmod +x "$KUBECTL_PLUGIN"
fi

# Create the K8S environment
terraform init
terraform $ACTION \
  ${AUTO_APPROVE} \
  --var="dh_user_email=${DOCKER_EMAIL}" \
  --var="dh_user_name=${DOCKER_USERNAME}" \
  --var="dh_user_password=${DOCKER_PASSWORD}" \
  --var="wspace_user_name=${WSPACE_USERNAME}" \
  --var="wspace_user_password=${WSPACE_PASSWORD}" \
  --var="nfs_server_address=${NFS_SERVER_ADDRESS}" \
  --var="hostname=test.${PUBLIC_IP}.nip.io" \
  --var="public_ip=${PUBLIC_IP}"

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
DEPLOYMENT_PUBLIC_IP=`${BIN_DIR}/../../bin/get-public-ip.sh` || unset DEPLOYMENT_PUBLIC_IP
if hash terraform 2>/dev/null
then
  DEPLOYMENT_NFS_SERVER="$(terraform output -state=../../creodias/terraform.tfstate -json | jq -r '.nfs_ip_address.value' 2>/dev/null)" || unset DEPLOYMENT_NFS_SERVER
  if [ "${DEPLOYMENT_NFS_SERVER}" = "null" ]; then unset DEPLOYMENT_NFS_SERVER; fi
fi
echo "Get nodes"
kubectl get nodes -o json
JSON=$(kubectl get nodes -o json)
echo "Json: ${JSON}"
# Note the 'local kube' IP-address in case we need it
LOCALKUBE_IP="$(kubectl get nodes -o json | jq -r '.items[0].status.addresses[] | select(.type == "InternalIP") | .address' 2>/dev/null)" || unset LOCALKUBE_IP
if [ -n "${LOCALKUBE_IP}" -a "${LOCALKUBE_IP}" != "null" ]
then
  echo "$LOCALKUBE_IP"
fi

# Check presence of environment variables
#
# If not supplied, try to derive IPs from Terraform (cloud infrastructure (preferred)), followed by minikube
PUBLIC_IP="${PUBLIC_IP:-${DEPLOYMENT_PUBLIC_IP:-${LOCALKUBE_IP:-none}}}"
NFS_SERVER_ADDRESS="${NFS_SERVER_ADDRESS:-${DEPLOYMENT_NFS_SERVER:-none}}"
if [ "${PUBLIC_IP}" = "none" ]; then echo "ERROR: invalid Public IP (${PUBLIC_IP}). Aborting..."; exit 1; fi
#
# Other details...
DOCKER_EMAIL="${DOCKER_EMAIL:-none@none.com}"
DOCKER_USERNAME="${DOCKER_USERNAME:-none}"
DOCKER_PASSWORD="${DOCKER_PASSWORD:-none}"
WSPACE_USERNAME="${WSPACE_USERNAME:-eoepca}"
WSPACE_PASSWORD="${WSPACE_PASSWORD:-telespazio}"
echo "Using PUBLIC_IP=${PUBLIC_IP}"
echo "Using NFS_SERVER_ADDRESS=${NFS_SERVER_ADDRESS}"

# Storage class
#
# If using minikube then set storage class to 'eoepca-host' (host storage OK for dev testing)
if [ "${PUBLIC_IP}" = "${LOCALKUBE_IP}" ]
then
  STORAGE_CLASS="${STORAGE_CLASS:-eoepca-host}"
  echo "INFO: using 'local' kubernetes with IP ${LOCALKUBE_IP} and storage class ${STORAGE_CLASS}"
fi
if [ -n "${STORAGE_CLASS}" ]; then VAR_STORAGE_CLASS="--var=storage_class=${STORAGE_CLASS}"; fi
#
# Also dynamic storage class (e.g. used by ADES)
if [ "${PUBLIC_IP}" = "${LOCALKUBE_IP}" ]
then
  DYNAMIC_STORAGE_CLASS="${DYNAMIC_STORAGE_CLASS:-standard}"
  echo "INFO: using dynamic storage class ${DYNAMIC_STORAGE_CLASS}"
fi
if [ -n "${DYNAMIC_STORAGE_CLASS}" ]; then VAR_DYNAMIC_STORAGE_CLASS="--var=dynamic_storage_class=${DYNAMIC_STORAGE_CLASS}"; fi

# Terraform plugins...
#
# kubectl plugin
KUBECTL_PLUGIN="terraform-provider-kubectl"
if [ ! -x "$KUBECTL_PLUGIN" ]
then
  echo Installing $KUBECTL_PLUGIN
  curl -Ls https://api.github.com/repos/gavinbunney/terraform-provider-kubectl/releases/tags/v1.5.1 \
    | jq -r '.assets[] | .browser_download_url | select(contains("linux-amd64"))' \
    | xargs -n 1 curl -Lo "$KUBECTL_PLUGIN"
  chmod +x "$KUBECTL_PLUGIN"
fi

# Consolidate to a local kubeconfig - less likely to confuse terraform
kubectl config view --minify --flatten > kubeconfig
export KUBECONFIG="$PWD/kubeconfig"

# Create the K8S environment
terraform init
count=$(( 1 ))
status=$(( 1 ))
while [ $status -ne 0 -a $count -le 1 ]
do
  echo "[INFO]  Deploy EOEPCA attempt: $count"
  terraform $ACTION \
    ${AUTO_APPROVE} \
    --var="dh_user_email=${DOCKER_EMAIL}" \
    --var="dh_user_name=${DOCKER_USERNAME}" \
    --var="dh_user_password=${DOCKER_PASSWORD}" \
    --var="wspace_user_name=${WSPACE_USERNAME}" \
    --var="wspace_user_password=${WSPACE_PASSWORD}" \
    --var="nfs_server_address=${NFS_SERVER_ADDRESS}" \
    ${VAR_STORAGE_CLASS} \
    ${VAR_DYNAMIC_STORAGE_CLASS} \
    --var="hostname=test.${PUBLIC_IP}.nip.io" \
    --var="public_ip=${PUBLIC_IP}"
  status=$(( $? ))
  echo "[INFO]  Deploy EOEPCA attempt: $count finished with status: $status"
  count=$(( count + 1 ))
done

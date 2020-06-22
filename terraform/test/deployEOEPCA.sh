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

# Check presence of environment variables
TRAVIS_BUILD_DIR="${TRAVIS_BUILD_DIR:-.}"
DOCKER_EMAIL="${DOCKER_EMAIL:-none@none@none.com}"
DOCKER_USERNAME="${DOCKER_USERNAME:-none}"
DOCKER_PASSWORD="${DOCKER_PASSWORD:-none}"
WSPACE_USERNAME="${WSPACE_USERNAME:-none}"
WSPACE_PASSWORD="${WSPACE_PASSWORD:-none}"

# CLUSTER_NODE_IP=$(sudo minikube ip)
CLUSTER_NODE_IP=$(kubectl get nodes -o jsonpath="{.items[0].status.addresses[0].address}")

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
  --var="nginx_ip=${CLUSTER_NODE_IP}" \
  --var="hostname=test.eoepca.org"

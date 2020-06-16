#!/bin/bash

# fail fast settings from https://dougrichardson.org/2018/08/03/fail-fast-bash-scripting.html
# set -euov pipefail
# Not supported in travis (xenial)
# shopt -s inherit_errexit

ACTION=$1
if [ -z "$ACTION" ]; then ACTION="apply"; fi

# Check presence of environment variables
TRAVIS_BUILD_DIR="${TRAVIS_BUILD_DIR:-.}"
DOCKER_EMAIL="${DOCKER_EMAIL:-none@none.com}"
DOCKER_USERNAME="${DOCKER_USERNAME:-none}"
DOCKER_PASSWORD="${DOCKER_PASSWORD:-none}"
WSPACE_USERNAME="${WSPACE_USERNAME:-none}"
WSPACE_PASSWORD="${WSPACE_PASSWORD:-none}"

# CLUSTER_NODE_IP=$(sudo minikube ip)
CLUSTER_NODE_IP=$(kubectl get nodes -o jsonpath="{.items[0].status.addresses[0].address}")

# Create the K8S environment
cd ${TRAVIS_BUILD_DIR}/terraform/test 
terraform init
terraform $ACTION \
  --var="dh_user_email=${DOCKER_EMAIL}" \
  --var="dh_user_name=${DOCKER_USERNAME}" \
  --var="dh_user_password=${DOCKER_PASSWORD}" \
  --var="wspace_user_name=${WSPACE_USERNAME}" \
  --var="wspace_user_password=${WSPACE_PASSWORD}" \
  --var="nginx_ip=${CLUSTER_NODE_IP}" \
  --var="hostname=something.eoepca.org"

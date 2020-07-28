#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

trap "cd '${ORIG_DIR}'" EXIT

function usage() {
  cat - <<EOF
Usage: $0 [ENDPOINT]
Open endpoint for an EOEPCA service.

Possible values for ENDPOINT:
  login      Login Server (Gluu)
  ades       Application Deployment and Execution Service (ADES)
             (a pure web service, and has no visual web interface)
  workspace  Nextcloud instance that is a stub for the Resource Management 'Workspace' component
             (used for outputs from ADES)
EOF
}

function get_public_ip() {
  # Scrape VM infrastructure topology from terraform outputs
  if hash terraform 2>/dev/null
  then
    DEPLOYMENT_PUBLIC_IP="$(terraform output -state=../creodias/terraform.tfstate -json | jq -r '.loadbalancer_fips.value[]' 2>/dev/null)" || unset DEPLOYMENT_PUBLIC_IP
  fi

  # Note minikube ip in case we need it
  if hash minikube 2>/dev/null; then MINIKUBE_IP=$(minikube ip 2>/dev/null) || unset MINIKUBE_IP; fi

  # Check presence of environment variables
  #
  # If not supplied, try to derive IPs from Terraform (cloud infrastructure (preferred)), followed by minikube
  PUBLIC_IP="${PUBLIC_IP:-${DEPLOYMENT_PUBLIC_IP:-${MINIKUBE_IP}}}"

  [ -n "${PUBLIC_IP}" ] && return 0 || return 1
}

function deduce_endpoint_url() {
  ENDPOINT="${1:-login}"

  case $ENDPOINT in
  login)
    URL="http://test.${PUBLIC_IP}.nip.io"
    ;;
  ades)
    URL="http://ades.test.${PUBLIC_IP}.nip.io"
    ;;
  workspace)
    URL="http://workspace.test.${PUBLIC_IP}.nip.io"
    ;;
  *)
    return 1
    ;;
  esac
}

function open_url() {
  echo "PUBLIC_IP=${PUBLIC_IP}"
  echo "URL for endpoint (${ENDPOINT}): ${URL}"
  xdg-open "${URL}" >/dev/null 2>&1
}

function main() {
  get_public_ip \
  && deduce_endpoint_url "$1" \
  && open_url \
  || usage
}

main "$@"

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
  # Check presence of environment variables
  #
  # If not supplied, try to derive IPs from Terraform (cloud infrastructure (preferred)), followed by minikube
  DEDUCED_PUBLIC_IP=`./get-public-ip.sh` || unset DEDUCED_PUBLIC_IP
  PUBLIC_IP="${PUBLIC_IP:-${DEDUCED_PUBLIC_IP}}"

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

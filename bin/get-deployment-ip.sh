#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

trap "cd '${ORIG_DIR}'" EXIT

# Get the deployment public IP address from the CREODIAS terraform state
function main() {
  DEPLOYMENT_PUBLIC_IP="$(terraform output -state=../creodias/terraform.tfstate -json | jq -r '.loadbalancer_fips.value[]' 2>/dev/null)" || unset DEPLOYMENT_PUBLIC_IP
  if [ -n "${DEPLOYMENT_PUBLIC_IP}" -a "${DEPLOYMENT_PUBLIC_IP}" != "null" ]
  then
    echo "$DEPLOYMENT_PUBLIC_IP"
    return 0
  else
    return 1
  fi
}

main "$@"

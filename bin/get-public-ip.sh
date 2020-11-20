#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

trap "cd '${ORIG_DIR}'" EXIT

# Deduce the k8s cluster public ip.
# * first, the deployed cluster
# * failing that, the local cluster
function main() {
  echo "public ip script called"
  DEPLOYMENT_PUBLIC_IP=`./get-deployment-ip.sh` || unset DEPLOYMENT_PUBLIC_IP
  LOCALKUBE_IP=`./get-localkube-ip.sh` || unset LOCALKUBE_IP
  PUBLIC_IP="${PUBLIC_IP:-${DEPLOYMENT_PUBLIC_IP:-${LOCALKUBE_IP}}}"

  if [ -n "${PUBLIC_IP}" -a "${PUBLIC_IP}" != "null" ]
  then
    echo "$PUBLIC_IP"
    return 0
  else
    return 1
  fi
}

main "$@"

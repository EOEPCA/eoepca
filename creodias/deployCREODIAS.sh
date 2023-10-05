#!/usr/bin/env bash

# fail fast settings from https://dougrichardson.org/2018/08/03/fail-fast-bash-scripting.html
# set -euov pipefail
# Not supported in travis (xenial)
# shopt -s inherit_errexit

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

trap "cd '${ORIG_DIR}'" EXIT

ACTION="${1:-apply}"

AUTO_APPROVE=
# if [ "$ACTION" = "apply" ]; then AUTO_APPROVE="--auto-approve"; fi

if test -z "$OS_CLOUD"
then
  echo "ERROR: must set OS_CLOUD environment variable"
  exit 1
fi

# terraform
export TF_LOG=DEBUG
terraform init
#
# keypair first
export TF_LOG_PATH="$PWD/debug-keypair.log"
rm "${TF_LOG_PATH}"
terraform ${ACTION} ${AUTO_APPROVE} -var-file=eoepca.tfvars -target=module.compute.openstack_compute_keypair_v2.k8s
if test "$ACTION" = "apply"
then
  keypair_ready=1
  keypair_name="kubernetes-${OS_CLOUD}"
  until test $keypair_ready -eq 0
  do
    echo "Waiting for keypair '${keypair_name}' to be ready"
    sleep 5
    keypair=`openstack keypair show "${keypair_name}" 2>/dev/null`
    keypair_ready=$?
  done
  echo "$keypair"
fi
#
# after keypair - everything else
export TF_LOG_PATH="$PWD/debug-deployment.log"
rm "${TF_LOG_PATH}"
echo "Proceeding with deployment..."
terraform ${ACTION} ${AUTO_APPROVE} -var-file=eoepca.tfvars

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
if [ "$ACTION" = "apply" ]; then AUTO_APPROVE="--auto-approve"; fi

export OS_CLOUD="${OS_CLOUD:-staging}"

# terraform
terraform init
#
# keypair first
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
echo "Proceeding with deployment..."
terraform ${ACTION} ${AUTO_APPROVE} -var-file=eoepca.tfvars

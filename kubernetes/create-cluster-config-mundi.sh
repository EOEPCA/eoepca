#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

trap "cd '${ORIG_DIR}'" EXIT

CLUSTER_NAME="${1}"
CLUSTER_YML_FILE="${2:-cluster.yml}"

if test -z "$CLUSTER_NAME"
then
  echo "ERROR: must provide <cluster-name> as command argument"
  echo "For example, $(basename "$0") staging"
  exit 1
fi

function master_nodes() {
  master_nodes=$(terraform output -state=../mundi/terraform.tfstate -json | jq -r '.k8s_master_ips.value[]' 2>/dev/null) || unset master_nodes
  for node in $master_nodes
  do
    cat - <<EOF
  - address: $node
    user: ubuntu
    role:
      - controlplane
      - etcd
EOF
  done
}

function worker_nodes() {
  worker_nodes=$(terraform output -state=../mundi/terraform.tfstate -json | jq -r '.k8s_node_ips.value[]' 2>/dev/null) || unset worker_nodes
  for node in $worker_nodes
  do
    cat - <<EOF
  - address: $node
    user: ubuntu
    role:
      - worker
EOF
  done
}

function bastion_host() {
  bastion=$(terraform output -state=../mundi/terraform.tfstate -json | jq -r '.bastion_fips.value[]' 2>/dev/null) || unset bastion
  cat - <<EOF
bastion_host:
  address: $bastion
  user: ubuntu
EOF
}

function docker_registry() {
  if test -n "$DOCKER_USER" -a -n "$DOCKER_PASSWORD"; then
    cat - <<EOF
private_registries:
  - user: ${DOCKER_USER}
    password: ${DOCKER_PASSWORD}
EOF
  fi
}

function cluster_yml() {
  cat - <<EOF
cluster_name: ${CLUSTER_NAME}
nodes:
$(master_nodes)
$(worker_nodes)

ingress:
  provider: none

addons_include:
  - ./ingress-controller/deploy-baremetal-creodias.yaml

$(bastion_host)

$(docker_registry)
EOF
}

function main() {
  cluster_yml | tee "${CLUSTER_YML_FILE}"
  echo -e "---\nOutput written to file: ${CLUSTER_YML_FILE}"
}

main

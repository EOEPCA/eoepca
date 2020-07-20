#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"
cd "${ORIG_DIR}"

trap "cd '${ORIG_DIR}'" EXIT

function master_nodes() {
  master_nodes=$(terraform output -state=../creodias/terraform.tfstate -json | jq -r '.k8s_master_ips.value[]')
  for node in $master_nodes
  do
    cat - <<EOF
    - address: $node
      user: eouser
      role:
        - controlplane
        - etcd
EOF
  done
}

function worker_nodes() {
  worker_nodes=$(terraform output -state=../creodias/terraform.tfstate -json | jq -r '.k8s_node_ips.value[]')
  for node in $worker_nodes
  do
    cat - <<EOF
    - address: $node
      user: eouser
      role:
        - worker
EOF
  done
}

function main() {
  cp cluster-template.yml cluster.yml
  m="$(master_nodes)"
  w="$(worker_nodes)"
  sed -i "s/MASTER_NODES/$m/" cluster.yml
  sed -i "s/WORKER_NODES/$w/" cluster.yml
}

main

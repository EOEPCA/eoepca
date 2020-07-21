#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"
cd "${ORIG_DIR}"

trap "cd '${ORIG_DIR}'" EXIT

CLUSTER_YML_FILE="${1:-cluster.yml}"

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

function bastion_host() {
  bastion=$(terraform output -state=../creodias/terraform.tfstate -json | jq -r '.bastion_fips.value[]')
  cat - <<EOF
bastion_host:
  address: $bastion
  user: eouser
EOF
}

function cluster_yml() {
  cat - <<EOF
nodes:
$(master_nodes)
$(worker_nodes)

ingress:
  provider: none

addons_include:
  - ./ingress-controller/ingress-nginx-nodeport.yml

$(bastion_host)
EOF
}

function main() {
  cluster_yml | tee "${CLUSTER_YML_FILE}"
  echo -e "---\nOutput written to file: ${CLUSTER_YML_FILE}"
}

main

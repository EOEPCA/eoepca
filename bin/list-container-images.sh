#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

onExit() {
  cd "${ORIG_DIR}"
}
trap onExit EXIT

# ref. https://kubernetes.io/docs/tasks/access-application-cluster/list-all-running-container-images/

# List all container images
#
# kubectl get pods --all-namespaces -o jsonpath="{.items[*].spec.containers[*].image}" |\
#   tr -s '[[:space:]]' '\n' |\
#   sort |\
#   uniq -c

# List container images by pod
#
kubectl get pods --all-namespaces \
  -o jsonpath='{range .items[*]}{"\n"}{.metadata.name}{":\t"}{range .spec.containers[*]}{.image}{", "}{end}{end}' |\
  sort

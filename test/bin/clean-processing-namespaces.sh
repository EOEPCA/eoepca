#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

trap "cd '${ORIG_DIR}'" EXIT

for f in $(kubectl get ns | grep s-expression | awk '{ print $1 }'); do
  kubectl delete ns/$f
done

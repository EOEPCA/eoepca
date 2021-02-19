#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

trap "cd '${ORIG_DIR}'" EXIT

for i in $(kubectl get pv -A | grep Released | cut -d' ' -f 1)
do
  # ssh eouser@192.168.123.10 ls -ld /data/dynamic/\*$i\*
  # ssh eouser@192.168.123.10 sudo rm -rf /data/dynamic/\*$i\*
  kubectl delete pv/$i
done

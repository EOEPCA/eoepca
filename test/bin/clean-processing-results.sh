#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

trap "cd '${ORIG_DIR}'" EXIT

for f in $(s3cmd ls s3://processing_results/wf-* | awk '{print $2}'); do
  s3cmd rm $f --recursive
done

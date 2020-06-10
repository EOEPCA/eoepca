#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

trap "cd '${ORIG_DIR}'" EXIT

docker build -f Dockerfile.alpine -t rconway/kubeproxy:alpine .
docker build -f Dockerfile.ubuntu -t rconway/kubeproxy:ubuntu .
docker tag rconway/kubeproxy:alpine rconway/kubeproxy:latest

for image in rconway/kubeproxy:alpine rconway/kubeproxy:ubuntu rconway/kubeproxy:latest
do
  docker push $image
done

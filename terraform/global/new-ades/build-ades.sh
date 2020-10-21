#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

trap "cd '${ORIG_DIR}'" EXIT

# eval $(minikube -p minikube docker-env)

docker build -t rconway/proc-ades:latest .

# eval $(minikube -p minikube docker-env -u)

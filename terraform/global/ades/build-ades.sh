#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

trap "cd '${ORIG_DIR}'" EXIT

TAG="0.2.4"

# eval $(minikube -p minikube docker-env)

docker build -t rconway/proc-ades:${TAG} .
docker push rconway/proc-ades:${TAG}
docker tag rconway/proc-ades:${TAG} rconway/proc-ades:latest
docker push rconway/proc-ades:latest

# eval $(minikube -p minikube docker-env -u)

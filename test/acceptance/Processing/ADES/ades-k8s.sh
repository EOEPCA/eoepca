#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"
cd "${ORIG_DIR}"

trap "cd '${ORIG_DIR}'" EXIT

ACTION=$1
if [ -z "$ACTION" ]; then ACTION="apply"; fi

function ades-yml() {
  cat - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: ades
  name: ades
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ades
  template:
    metadata:
      labels:
        app: ades
    spec:
      containers:
      - image: eoepca/eoepca-ades-core:travis_develop_25
        name: eoepca-ades-core
---
apiVersion: v1
kind: Service
metadata:
  labels:
    app: ades
  name: ades
spec:
  ports:
  - port: 7777
    protocol: TCP
    targetPort: 80
  selector:
    app: ades
  type: LoadBalancer
EOF
}

ades-yml | kubectl $ACTION -f -

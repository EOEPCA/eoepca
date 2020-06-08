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
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: eoepca-pv
  labels:
    type: local
spec:
  storageClassName: manual
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: standard
  hostPath:
    path: "/mnt/data"
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: eoepca-pvc
spec:
  accessModes:
  - ReadWriteOnce
  storageClassName: standard
  resources:
    requests:
      storage: 3Gi
EOF
}

ades-yml | kubectl $ACTION -f -

# argo
argo_version="v2.8.1"
kubectl create namespace argo
kubectl apply -n argo -f https://raw.githubusercontent.com/argoproj/argo/${argo_version}/manifests/install.yaml
kubectl create rolebinding default-admin --clusterrole=admin --serviceaccount=default:default


#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

onExit() {
  cd "${ORIG_DIR}"
}

NAMESPACE="um"

# Prepare tar files
cd customizations/oxauth
tar -czvf ../../customizations_oxauth.tar.gz .
cd ../oxtrust
tar -czvf ../../customizations_oxtrust.tar.gz .
cd ../../

# Create and apply ConfigMap from tar files
kubectl create configmap front-customizations -n $NAMESPACE --from-file=customizations_oxauth.tar.gz --from-file=customizations_oxtrust.tar.gz -o yaml --dry-run=client | kubectl replace -f -
rm -rf ./*.tar.gz

# Restart oxauth and oxtrust to pick-up customizations
OXAUTH=$(kubectl get deployment -n $NAMESPACE | grep oxauth | awk '{print $1}')
OXTRUST=$(kubectl get statefulsets -n $NAMESPACE | grep oxtrust | awk '{print $1}')
kubectl scale deployment $OXAUTH --replicas 0 -n $NAMESPACE
kubectl scale statefulsets $OXTRUST --replicas 0 -n $NAMESPACE
sleep 5
kubectl scale deployment $OXAUTH --replicas 1 -n $NAMESPACE
kubectl scale statefulsets $OXTRUST --replicas 1 -n $NAMESPACE

#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"
cd "${ORIG_DIR}"

trap "cd '${ORIG_DIR}'" EXIT

ACTION=$1
if [ -z "$ACTION" ]; then ACTION="apply"; fi

# webdav secret
function eoepcawebdavsecret() {
  webdav_user="eoepca"
  webdav_password="telespazio"
  cat - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: eoepcawebdavsecret
type: Opaque
data:
  username: $(echo -n $webdav_user | base64)
  password: $(echo -n $webdav_password | base64)
EOF
}
eoepcawebdavsecret | kubectl $ACTION -f -

# argo
# argo_version="v2.8.1"
# kubectl create namespace argo
# kubectl apply -n argo -f https://raw.githubusercontent.com/argoproj/argo/${argo_version}/manifests/install.yaml
# kubectl create rolebinding default-admin --clusterrole=admin --serviceaccount=default:default
kubectl $ACTION -f k8s/argo-namespace.yml
kubectl $ACTION -n argo -f k8s/argo.yml
kubectl $ACTION -f k8s/default-admin-role.yml

# ADES
kubectl $ACTION -f k8s/ades.yml

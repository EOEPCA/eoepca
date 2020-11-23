#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

trap "cd '${ORIG_DIR}'" EXIT

mkdir -p $HOME/.local/bin

VERSION="v1.14.2"

# minikube: download and install locally
if hash minikube 2>/dev/null
then
  INSTALLED_VERSION=`minikube version -o json | jq -r .minikubeVersion`
  echo "Current installed version of minikube is ${INSTALLED_VERSION}"
fi
if [ "${INSTALLED_VERSION}" = "${VERSION}" ]
then
  echo "Using existing minikube version ${VERSION}"
else
  echo "Download and install minikube version ${VERSION}..."
  curl -sLo $HOME/.local/bin/minikube https://github.com/kubernetes/minikube/releases/download/${VERSION}/minikube-linux-amd64 \
    && chmod +x $HOME/.local/bin/minikube
fi

# If MINIKUBE_MODE is not set, and USER is vagrant, deduce we are running in a VM, so use 'native' mode
MINIKUBE_MODE="$1"
if [ -z "${MINIKUBE_MODE}" -a "${USER}" = "vagrant" ]; then MINIKUBE_MODE="native"; fi

# Extra options
OPTIONS="--memory=8g --cpus=4"

# Use default location for kubeconfig
unset KUBECONFIG

# minikube (native)
if [ "${MINIKUBE_MODE}" = "native" ]
then
  if hash conntrack 2>/dev/null
  then
    # start minikube
    # - default container runtime is docker - see https://minikube.sigs.k8s.io/docs/handbook/config/#runtime-configuration
    echo "Start minikube (native), and wait for cluster..."
    export CHANGE_MINIKUBE_NONE_USER=true
    sudo -E $HOME/.local/bin/minikube start ${OPTIONS} --driver=none --addons ingress --wait "all"
  else
    echo "ERROR: conntrack must be installed for minikube driver='none', e.g. 'sudo apt install conntrack'. Aborting..."
    exit 1
  fi
# minikube docker
else
  if [ "${MINIKUBE_MODE}" = "github" ]
    then
      echo "Start minikube (github), and wait for cluster..."
      minikube start --memory=4g --cpus=2 --addons ingress --wait "all"
  else
    # start minikube
    # - default container runtime is docker - see https://minikube.sigs.k8s.io/docs/handbook/config/#runtime-configuration
    echo "Start minikube (default), and wait for cluster..."
    minikube start ${OPTIONS} --addons ingress --wait "all"
  fi
fi

echo "...READY"
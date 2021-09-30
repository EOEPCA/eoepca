#!/usr/bin/env bash
#---
# Assumes Ubuntu 18.04 (bionic)
#---

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

trap "cd '${ORIG_DIR}'" EXIT

USER=$1
if [ -z "$USER" ]; then USER=eouser; fi

echo "Setting up node for USER=${USER}"

# Install docker
if ! hash docker 2>/dev/null
then
  export VERSION=19.03
  curl -sfLo docker.sh https://get.docker.com
  chmod +x docker.sh
  let status=1
  while test $status -ne 0
  do
    ./docker.sh
    let status=$?
    echo "Docker install status: ${status}"
    sleep 5
  done
  rm docker.sh
  sudo usermod -aG docker ${USER}
fi

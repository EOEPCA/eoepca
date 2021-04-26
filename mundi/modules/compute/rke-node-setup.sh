#!/usr/bin/env bash
#---
# Assumes Ubuntu 18.04 (bionic)
#---

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

trap "cd '${ORIG_DIR}'" EXIT

USER=$1
if [ -z "$USER" ]; then USER=ubuntu; fi

echo "Setting up node for USER=${USER}"

# Install docker
if ! hash docker 2>/dev/null
then
  export VERSION=19.03
  curl -sfL https://get.docker.com | sh -s -
  sudo usermod -aG docker ${USER}
fi

sudo sed -i 's/AllowTcpForwarding no/AllowTcpForwarding yes/' /etc/ssh/sshd_config
sudo systemctl restart sshd.service

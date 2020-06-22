#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

trap "cd '${ORIG_DIR}'" EXIT

mkdir -p $HOME/.local/bin

# terraform
if ! unzip --help >/dev/null 2>&1
then
  sudo apt-get -y install unzip
fi
curl -sLo terraform.zip https://releases.hashicorp.com/terraform/0.12.26/terraform_0.12.26_linux_amd64.zip
unzip terraform.zip
rm -f terraform.zip
chmod +x terraform
mv terraform $HOME/.local/bin

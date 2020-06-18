#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

trap "cd '${ORIG_DIR}'" EXIT

mkdir -p $HOME/.local/bin

# terraform
sudo apt-get -y install p7zip-full
curl -sLo terraform.zip https://releases.hashicorp.com/terraform/0.12.26/terraform_0.12.26_linux_amd64.zip
7z x terraform.zip
rm -f terraform.zip
chmod +x terraform
mv terraform $HOME/.local/bin

#!/usr/bin/env bash
#---
# Assumes Ubuntu 18.04 (bionic)
#---

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"
cd "${ORIG_DIR}"

trap "cd '${ORIG_DIR}'" EXIT

# Install the NFS server package
apt-get update
apt-get -y install nfs-kernel-server

# Create the root export directory
mkdir -p /data && chown nobody:nogroup /data && chmod 777 /data

# Create the export subdirectories
for exportdir in userman proc resman dynamic
do
  mkdir -p /data/${exportdir} && chown nobody:nogroup /data/${exportdir} && chmod 777 /data/${exportdir}
  grep ${exportdir} /etc/exports 2>/dev/null || echo "/data/${exportdir}  *(rw,no_root_squash,no_subtree_check)" >> /etc/exports
done

# Restart the NFS service
systemctl restart nfs-kernel-server

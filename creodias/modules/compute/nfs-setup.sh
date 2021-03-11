#!/usr/bin/env bash
#---
# Assumes Ubuntu 18.04 (bionic)
#---
ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

trap "cd '${ORIG_DIR}'" EXIT

# Install the NFS server package
sudo apt-get update
sudo apt-get -y install nfs-kernel-server

# Create the root export directory
sudo mkdir -p /data && chown nobody:nogroup /data && chmod 777 /data

# This creates the partition on the attached volume
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | sudo fdisk /dev/sdb
  o # clear the in memory partition table
  n # new partition
  p # primary partition
  1 # partition number 1
    # default - start at beginning of disk
    # default, extend partition to end of disk
  w # write the partition table
  q # and we're done
EOF
# Format the partition
sudo mkfs -t ext4 /dev/sdb1
# Mounts the partition
sudo mount /dev/sdb1 /data
# Adds it to the auto-mount
grep sdb1 /etc/fstab 2>/dev/null || sudo bash -c "echo '/dev/sdb1 /data ext4 defaults 1 2' >> /etc/fstab"
# Create the export subdirectories
for exportdir in userman proc resman dynamic
do
  sudo mkdir -p /data/${exportdir} && sudo chown nobody:nogroup /data/${exportdir} && sudo chmod 777 /data/${exportdir}
  grep ${exportdir} /etc/exports 2>/dev/null || sudo bash -c "echo '/data/${exportdir}  *(rw,no_root_squash,no_subtree_check)' >> /etc/exports"
done

# Restart the NFS service
sudo systemctl restart nfs-kernel-server

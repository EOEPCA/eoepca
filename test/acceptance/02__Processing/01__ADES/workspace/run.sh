#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

trap "cd '${ORIG_DIR}'" EXIT

IMAGE=nextcloud:19

docker run --rm \
  --name workspace \
  -e SQLITE_DATABASE= \
  -e NEXTCLOUD_ADMIN_USER=eoepca \
  -e NEXTCLOUD_ADMIN_PASSWORD=telespazio \
  -e NEXTCLOUD_TRUSTED_DOMAINS='"*"' \
  -v workspace:/var/www/html \
  -p 5555:80 \
  $IMAGE

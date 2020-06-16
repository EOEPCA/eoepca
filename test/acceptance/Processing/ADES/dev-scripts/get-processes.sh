#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

trap "cd '${ORIG_DIR}'" EXIT

URL_HOST="$1"
if [ -z "$URL_HOST" ]; then URL_HOST="localhost:7777"; fi

echo "Get jobs..."
curl -v -s -L "http://${URL_HOST}/wps3/processes" \
  -H "accept: application/json" \
  | jq
echo

#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

trap "cd '${ORIG_DIR}'" EXIT

URL_HOST="$1"
if [ -z "$URL_HOST" ]; then URL_HOST="localhost:7777"; fi

echo "Deploy..."
curl -v -L -X POST "http://${URL_HOST}/wps3/processes/eoepcaadesundeployprocess/jobs" \
  -H "accept: application/json" \
  -H "Prefer: respond-async" \
  -H "Content-Type: application/json" \
  -d@../eo_metadata_generation_1_0_undeploy.json
echo

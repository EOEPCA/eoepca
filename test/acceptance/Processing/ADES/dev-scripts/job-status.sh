#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

trap "cd '${ORIG_DIR}'" EXIT

JOB_ID="$1"
if [ -z "$JOB_ID" ]; then echo "ERROR: missing JOB ID"; exit 1; fi

URL_HOST="$2"
if [ -z "$URL_HOST" ]; then URL_HOST="localhost:7777"; fi

echo "Get job status..."
curl -v -s -L "http://${URL_HOST}/watchjob/processes/eo_metadata_generation_1_0/jobs/${JOB_ID}" \
  -H "accept: application/json" \
  | jq

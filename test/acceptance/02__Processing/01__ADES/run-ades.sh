#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

trap "cd '${ORIG_DIR}'" EXIT

docker run --rm  -d --name zoo -p 7777:80 eoepca/eoepca-ades-core:travis_develop_25

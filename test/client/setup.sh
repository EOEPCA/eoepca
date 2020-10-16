#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

trap "cd '${ORIG_DIR}'" EXIT

python3 -m venv venv
source venv/bin/activate
python -m pip install -U pip
pip install -U -r requirements.txt

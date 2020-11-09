#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

trap "cd '${ORIG_DIR}'" EXIT

mkdir -p $HOME/.local/bin

chrome_version="$(google-chrome-stable --version | awk '{ print $3 }' | awk -F. '{ print $1"."$2"."$3 }')"
echo "chrome version: ${chrome_version}"
driver_version="$(curl -sL https://chromedriver.storage.googleapis.com/LATEST_RELEASE_${chrome_version})"
echo "driver version: ${driver_version}"

curl -sLO https://chromedriver.storage.googleapis.com/${driver_version}/chromedriver_linux64.zip
unzip chromedriver_linux64.zip
rm chromedriver_linux64.zip
mv chromedriver $HOME/.local/bin

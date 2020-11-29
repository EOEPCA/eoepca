#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

trap "cd '${ORIG_DIR}'" EXIT

mkdir -p $HOME/.local/bin

# Ensure google chrome is installed
if ! hash google-chrome >/dev/null 2>&1; then
  if hash apt-get >/dev/null 2>&1; then
    echo "Downloading and installing google chrome..."
    curl -sLO https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    sudo apt-get -y install ./google-chrome-stable_current_amd64.deb
    rm ./google-chrome-stable_current_amd64.deb
  else
    echo "ERROR: google-chrome is required. Aborting..."
    exit 1
  fi
fi

# Use installed chrome version to determine which chromedriver version to install
chrome_version="$(google-chrome --version | awk '{ print $3 }' | awk -F. '{ print $1"."$2"."$3 }')"
echo "chrome version: ${chrome_version}"
driver_version="$(curl -sL https://chromedriver.storage.googleapis.com/LATEST_RELEASE_${chrome_version})"
echo "driver version: ${driver_version}"

echo "Downloading and installing chromedriver version ${driver_version} for google chrome ${chrome_version}..."
curl -sLO https://chromedriver.storage.googleapis.com/${driver_version}/chromedriver_linux64.zip
unzip chromedriver_linux64.zip
rm chromedriver_linux64.zip
mv chromedriver $HOME/.local/bin

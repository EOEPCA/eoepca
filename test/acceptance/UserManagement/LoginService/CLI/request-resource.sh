#!/usr/bin/env bash

USAGE="Usage: request-resource.sh [-S (toggle https on)] -s <resource-server-endpoint> -r </path/to/resource> [-t <RPT>]"
RS_ENDPOINT=""
RESOURCE_PATH=""
HTTP="http://"
TOKEN=""

while getopts ":t:Ss:r:" opt; do
  case ${opt} in
    r ) RESOURCE_PATH=$OPTARG
      ;;
    s ) RS_ENDPOINT=$OPTARG
      ;;
    S ) HTTP="https://"
      ;;
    t ) TOKEN=$OPTARG
      ;;
    \? )
        echo "Invalid option: -$OPTARG" 1>&2
        echo "$USAGE"
        exit 1
      ;;
  esac
done

if [ -z "$RESOURCE_PATH" ]; then
    echo "-r option mandatory"
    echo $USAGE
    exit 2
fi

if [ -z "$RS_ENDPOINT" ]; then
    echo "-s option mandatory"
    echo $USAGE
    exit 3
fi

if [ ! -z "$TOKEN" ]; then
    curl -k -v "$HTTP""$RS_ENDPOINT""$RESOURCE_PATH" -H "Authorization: Bearer $TOKEN"
else
    curl -k -v "$HTTP""$RS_ENDPOINT""$RESOURCE_PATH"
fi



#!/usr/bin/env bash
USAGE="Usage: tkn.sh -t <token_endpoint> -i <client_id> -p <client_secret>" 
TOKEN_ENDPOINT=""
HTTP="http://"
URL=""
CLIENT_ID=""
CLIENT_SECRET=""
SCOPES=""
SPACE="%20"
CLAIM_TOKEN=""

while getopts ":t:i:p:" opt; do
  case ${opt} in
    t ) TOKEN_ENDPOINT=$OPTARG
      ;;
    i ) CLIENT_ID=$OPTARG
      ;;
    p ) CLIENT_SECRET=$OPTARG
      ;;
    \? )
        echo "Invalid option: -$OPTARG" 1>&2
        echo "$USAGE"
        exit 1
      ;;
  esac
done
curl -k -v -XPOST "$TOKEN_ENDPOINT" -H 'cache-control: no-cache' -d "grant_type=password&client_id=$CLIENT_ID&client_secret=$CLIENT_SECRET&username=UserA&password=defaultPWD&scope=openid" > ./01__UserManagement/03__PDP_Engine/2.txt
curl -k -v -XPOST "$TOKEN_ENDPOINT" -H 'cache-control: no-cache' -d "grant_type=password&client_id=$CLIENT_ID&client_secret=$CLIENT_SECRET&username=UserB&password=defaultPWD&scope=openid" > ./01__UserManagement/03__PDP_Engine/3.txt

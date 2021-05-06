#!/usr/bin/env bash
USAGE="Usage: tkn.sh -t <token_endpoint> -i <client_id> -s <client_secret> -u <user_name> -p <user_password> -f <output-file>"
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
    s ) CLIENT_SECRET=$OPTARG
      ;;
    u ) USER_NAME=$OPTARG
      ;;
    p ) USER_PASSWORD=$OPTARG
      ;;
    f ) OUTPUT_FILE=$OPTARG
      ;;
    \? )
        echo "Invalid option: -$OPTARG" 1>&2
        echo "$USAGE"
        exit 1
      ;;
  esac
done
curl -k -v -XPOST "$TOKEN_ENDPOINT" -H 'cache-control: no-cache' -d "grant_type=password&client_id=$CLIENT_ID&client_secret=$CLIENT_SECRET&username=${USER_NAME}&password=${USER_PASSWORD}&scope=openid" > "${OUTPUT_FILE}"

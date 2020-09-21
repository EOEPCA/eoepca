#!/usr/bin/env bash


USAGE="Usage: id.sh -t <token_endpoint> -i <client_id> -p <client_secret>" 
TOKEN_ENDPOINT=""
HTTP="http://"
TICKET=""
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
curl -k -v -XPOST "$TOKEN_ENDPOINT" -H "cache-control: no-cache" -d "scope=openid&grant_type=password&username=admin&password=admin_Abcd1234%23&client_id=$CLIENT_ID&client_secret=$CLIENT_SECRET" > ./01__UserManagement/01__LoginService/1.txt
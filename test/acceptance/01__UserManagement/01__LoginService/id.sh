#!/usr/bin/env bash


#USAGE="Usage: id.sh -t <token_endpoint> -i <client_id> -p <client_secret> -v -d -b" 
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

echo $1
if  [[ $1 = "-v" ]]; then
  curl -k -v -XPOST "$TOKEN_ENDPOINT" -H "cache-control: no-cache" -d "scope=openid&grant_type=password&username=admin&password=admin_Abcd1234%23&client_id=$CLIENT_ID&client_secret=$CLIENT_SECRET"
fi
if  [[ $1 = "-d" ]]; then
  curl -k -v -XPOST "$TOKEN_ENDPOINT" -H 'Content-Type application/x-www-form-urlencoded, accept application/json' -d "grant_type=password&client_id=$CLIENT_ID&client_secret=$CLIENT_SECRET&username=UserA&password=defaultPWD&scope=openid,permission,uma_protection&uri="
fi
if  [[ $1 = "-b" ]]; then
  curl -k -v -XPOST "$TOKEN_ENDPOINT" -H 'Content-Type application/x-www-form-urlencoded, accept application/json' -d "grant_type=password&client_id=$CLIENT_ID&client_secret=$CLIENT_SECRET&username=UserB&password=defaultPWD&scope=openid,permission,uma_protection&uri="
fi
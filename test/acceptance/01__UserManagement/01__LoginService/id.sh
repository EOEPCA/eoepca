#!/usr/bin/env bash


USAGE="Usage: id.sh -t <token_endpoint> -i <client_id> -p <client_secret> -v -d -b" 
TOKEN_ENDPOINT=""
HTTP="http://"
TICKET=""
CLIENT_ID=""
CLIENT_SECRET=""
SCOPES=""
SPACE="%20"
CLAIM_TOKEN=""

while getopts ":t:i:p:v:d:b:" opt; do
  case ${opt} in
    t ) TOKEN_ENDPOINT=$OPTARG
      ;;
    i ) CLIENT_ID=$OPTARG
      ;;
    p ) CLIENT_SECRET=$OPTARG
      ;;
    v )
        echo "Me explicas porfa?"
      ;; 
    \? )
        echo "Invalid option: -$OPTARG" 1>&2
        echo "$USAGE"
        exit 1
      ;;
  esac
done
curl -k -v -XPOST "$TOKEN_ENDPOINT" -H "cache-control: no-cache" -d "scope=openid&grant_type=password&username=admin&password=admin_Abcd1234%23&client_id=$CLIENT_ID&client_secret=$CLIENT_SECRET" > ./01__UserManagement/01__LoginService/1.txt
curl -k -v -XPOST "$TOKEN_ENDPOINT" -H 'cache-control: no-cache' -d "grant_type=password&client_id=$CLIENT_ID&client_secret=$CLIENT_SECRET&username=UserA&password=defaultPWD&scope=openid" > ./01__UserManagement/03__PDP_Engine/2.txt
curl -k -v -XPOST "$TOKEN_ENDPOINT" -H 'cache-control: no-cache' -d "grant_type=password&client_id=$CLIENT_ID&client_secret=$CLIENT_SECRET&username=UserB&password=defaultPWD&scope=openid" > ./01__UserManagement/03__PDP_Engine/3.txt

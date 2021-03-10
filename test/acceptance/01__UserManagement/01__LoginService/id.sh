#!/usr/bin/env bash


USAGE="Usage: id.sh -t <token_endpoint> -i <client_id> -p <client_secret> -u <user> -w <pwd>" 
TOKEN_ENDPOINT=""
HTTP="http://"
TICKET=""
CLIENT_ID=""
CLIENT_SECRET=""
SCOPES=""
SPACE="%20"
CLAIM_TOKEN=""

while getopts ":t:i:p:u:w:" opt; do
  case ${opt} in
    t ) TOKEN_ENDPOINT=$OPTARG
      ;;
    i ) CLIENT_ID=$OPTARG
      ;;
    p ) CLIENT_SECRET=$OPTARG
      ;;
    u ) USER=$OPTARG
      ;;
    w ) PWD=$OPTARG
      ;;
    \? )
        echo "Invalid option: -$OPTARG" 1>&2
        echo "$USAGE"
        exit 1
      ;;
  esac
done
curl -k -v -XPOST "$TOKEN_ENDPOINT" -H "cache-control: no-cache" -d "scope=openid%20user_name&grant_type=password&username=$USER&password=$PWD&client_id=$CLIENT_ID&client_secret=$CLIENT_SECRET" > ./01__UserManagement/01__LoginService/1.txt

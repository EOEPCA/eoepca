#!/usr/bin/env bash


USAGE="Usage: setup.sh -t <token> -u <url>" 
TOKEN_ENDPOINT=""
HTTP="http://"
URL=""
CLIENT_ID=""
CLIENT_SECRET=""
SCOPES=""
SPACE="%20"
CLAIM_TOKEN=""

while getopts ":t:u:" opt; do
  case ${opt} in
    t ) TOKEN=$OPTARG
      ;;
    u ) URL=$OPTARG
      ;;
    \? )
        echo "Invalid option: -$OPTARG" 1>&2
        echo "$USAGE"
        exit 1
      ;;
  esac
done
echo $URL
curl -k -v -XPOST "$URL" -H "content-type : application/json, Authorization: Bearer $TOKEN" -d '{"resource_scopes":[ "Authenticated"],"icon_uri":"/","name":"ADES" }' > ./01__UserManagement/01__LoginService/1.txt

#!/usr/bin/env bash

# It depends on python3 and WellKnownHandler library!

USAGE="Usage: get-rpt.sh [-S (toggle https on)] -a <auth-server-hostname> -t <ticket> -i <client_id> -p <client_secret> -s '<scope1 scope2>' -c <id_token>"
AS_ENDPOINT=""
HTTP="http://"
TICKET=""
CLIENT_ID=""
CLIENT_SECRET=""
SCOPES=""
SPACE="%20"
CLAIM_TOKEN=""

while getopts ":t:Sa:i:p:s:c:" opt; do
  case ${opt} in
    a ) AS_ENDPOINT=$OPTARG
      ;;
    S ) HTTP="https://"
      ;;
    t ) TICKET=$OPTARG
      ;;
    i ) CLIENT_ID=$OPTARG
      ;;
    p ) CLIENT_SECRET=$OPTARG
      ;;
    s ) SCOPES=$OPTARG
      ;;
    c ) CLAIM_TOKEN=$OPTARG
      ;;
    \? )
        echo "Invalid option: -$OPTARG" 1>&2
        echo "$USAGE"
        exit 1
      ;;
  esac
done

if [ -z "$AS_ENDPOINT" ]; then
    echo "-a option mandatory"
    echo $USAGE
    exit 2
fi

if [ -z "$TICKET" ]; then
    echo "-t option mandatory"
    echo $USAGE
    exit 2
fi

if [ -z "$CLIENT_ID" ]; then
    echo "-i option mandatory"
    echo $USAGE
    exit 2
fi

if [ -z "$CLIENT_SECRET" ]; then
    echo "-p option mandatory"
    echo $USAGE
    exit 2
fi

if [ -z "$SCOPES" ]; then
    echo "-s option mandatory"
    echo $USAGE
    exit 2
fi

if [ -z "$CLAIM_TOKEN" ]; then
    echo "-c option mandatory"
    echo $USAGE
    exit 2
fi

TOKEN_ENDPOINT=$(python3 -c 'from WellKnownHandler import WellKnownHandler, TYPE_OIDC, KEY_OIDC_TOKEN_ENDPOINT; h = WellKnownHandler("'"$HTTP""$AS_ENDPOINT"'", secure=False); print(h.get(TYPE_OIDC, KEY_OIDC_TOKEN_ENDPOINT))')
SCOPES=${SCOPES// /$SPACE}

curl -k -v -XPOST "$TOKEN_ENDPOINT" -H "content-type: application/x-www-form-urlencoded" -H "cache-control: no-cache" -d "claim_token_format=http://openid.net/specs/openid-connect-core-1_0.html#IDToken&claim_token=$CLAIM_TOKEN&ticket=$TICKET&grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Auma-ticket&client_id=$CLIENT_ID&client_secret=$CLIENT_SECRET&scope=$SCOPES"


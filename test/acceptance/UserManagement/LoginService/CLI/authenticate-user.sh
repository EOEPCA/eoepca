#!/usr/bin/env bash

# It depends on python3 and WellKnownHandler library!

USAGE="Usage: authenticate-user.sh [-S (toggle https on)] -a <auth-server-hostname> -i <client_id> -p <client_secret> -s '<scope1 scope2>' -u <user> -w <user_password> -r <redirect_uri> "
AS_ENDPOINT=""
HTTP="http://"
TICKET=""
CLIENT_ID=""
CLIENT_SECRET=""
SCOPES=""
SPACE="%20"
USER=""
U_PWD=""
REDIRECT_URI=""

while getopts ":Sa:i:p:s:u:w:r:" opt; do
  case ${opt} in
    a ) AS_ENDPOINT=$OPTARG
      ;;
    S ) HTTP="https://"
      ;;
    i ) CLIENT_ID=$OPTARG
      ;;
    p ) CLIENT_SECRET=$OPTARG
      ;;
    s ) SCOPES=$OPTARG
      ;;
    u ) USER=$OPTARG
      ;;
    w ) U_PWD=$OPTARG
      ;;
    r ) REDIRECT_URI=$OPTARG
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

if [ -z "$USER" ]; then
    echo "-u option mandatory"
    echo $USAGE
    exit 2
fi

if [ -z "$U_PWD" ]; then
    echo "-w option mandatory"
    echo $USAGE
    exit 2
fi

if [ -z "$REDIRECT_URI" ]; then
    echo "-r option mandatory"
    echo $USAGE
    exit 2
fi

TOKEN_ENDPOINT=$(python3 -c 'from WellKnownHandler import WellKnownHandler, TYPE_OIDC, KEY_OIDC_TOKEN_ENDPOINT; h = WellKnownHandler("'"$HTTP""$AS_ENDPOINT"'", secure=False); print(h.get(TYPE_OIDC, KEY_OIDC_TOKEN_ENDPOINT))')
SCOPES=${SCOPES// /$SPACE}

curl -k -v -XPOST "$TOKEN_ENDPOINT" -H "cache-control: no-cache" -d "redirect_uri=$REDIRECT_URI&scope=$SCOPES&grant_type=password&username=$USER&password=$U_PWD&client_id=$CLIENT_ID&client_secret=$CLIENT_SECRET"


USAGE="Usage: rpt.sh [-S (toggle https on)] -a <auth-server-hostname> -t <ticket> -i <client_id> -p <client_secret> -s '<scope1 scope2>' -c <id_token>"
TOKEN_ENDPOINT=""
HTTP="http://"
TICKET=""
CLIENT_ID=""
CLIENT_SECRET=""
SCOPES=""
SPACE="%20"
CLAIM_TOKEN=""

while getopts ":t:Sa:i:p:s:c:" opt; do
  case ${opt} in
    a ) TOKEN_ENDPOINT=$OPTARG
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

curl -k -v -XPOST "$TOKEN_ENDPOINT" -H "content-type: application/x-www-form-urlencoded" -H "cache-control: no-cache" -d "claim_token_format=http://openid.net/specs/openid-connect-core-1_0.html#IDToken&claim_token=$CLAIM_TOKEN&ticket=$TICKET&grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Auma-ticket&client_id=$CLIENT_ID&client_secret=$CLIENT_SECRET&scope=openid"


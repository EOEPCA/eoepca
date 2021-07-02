#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

trap "cd '${ORIG_DIR}'" EXIT

if test $# -lt 1; then
  appname="$(basename "$0")"
  cat - <<EOF
ERROR - resource id not specified
Usage:
  ${appname} <resource-id>
EOF
  exit 1
fi

resourceId="$1"

# ades-pep
echo -n "Delete resource ${resourceId} from ades-pep..."
kubectl -n proc exec -it svc/proc-ades-pep -c proc-ades-pep -- management_tools remove -r ${resourceId}
echo " done"

# pdp
echo -n "Delete resource ${resourceId} from pdp..."
kubectl exec -it svc/pdp-engine -c pdp-engine -- management_tools remove -r ${resourceId}
echo " done"

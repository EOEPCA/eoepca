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

# combined-rm-pep
echo -n "Delete resource ${resourceId} from combined-rm-pep..."
kubectl -n rm exec -it svc/combined-rm-pep -c combined-rm-pep -- management_tools remove -r ${resourceId}
echo " done"

# # resource-catalogue-pep
# echo -n "Delete resource ${resourceId} from resource-catalogue-pep..."
# kubectl -n rm exec -it svc/resource-catalogue-pep -c resource-catalogue-pep -- management_tools remove -r ${resourceId}
# echo " done"

# # data-access-pep
# echo -n "Delete resource ${resourceId} from data-access-pep..."
# kubectl -n rm exec -it svc/data-access-pep -c data-access-pep -- management_tools remove -r ${resourceId}
# echo " done"

# ades-pep
echo -n "Delete resource ${resourceId} from ades-pep..."
kubectl -n proc exec -it svc/ades-pep -c ades-pep -- management_tools remove -r ${resourceId}
echo " done"

# workspace-api-pep
echo -n "Delete resource ${resourceId} from workspace-api-pep..."
kubectl -n rm exec -it svc/workspace-api-pep -c workspace-api-pep -- management_tools remove -r ${resourceId}
echo " done"

# dummy-service-pep
echo -n "Delete resource ${resourceId} from dummy-service-pep..."
kubectl -n test exec -it svc/dummy-service-pep -c dummy-service-pep -- management_tools remove -r ${resourceId}
echo " done"

# pdp
echo -n "Delete resource ${resourceId} from pdp..."
kubectl -n um exec -it svc/pdp-engine -c pdp-engine -- management_tools remove -r ${resourceId}
echo " done"

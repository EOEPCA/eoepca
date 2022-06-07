#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

trap "cd '${ORIG_DIR}'" EXIT

# combined-rm-pep
echo -n "Dumping policy for combined-rm-pep to $ORIG_DIR/combined-rm-pep.json..."
kubectl -n rm exec -it svc/combined-rm-pep -c combined-rm-pep -- management_tools list --all | jq > "$ORIG_DIR"/combined-rm-pep.json
echo " done"

# # resource-catalogue-pep
# echo -n "Dumping policy for resource-catalogue-pep to $ORIG_DIR/resource-catalogue-pep.json..."
# kubectl -n rm exec -it svc/resource-catalogue-pep -c resource-catalogue-pep -- management_tools list --all | jq > "$ORIG_DIR"/resource-catalogue-pep.json
# echo " done"

# # data-access-pep
# echo -n "Dumping policy for data-access-pep to $ORIG_DIR/data-access-pep.json..."
# kubectl -n rm exec -it svc/data-access-pep -c data-access-pep -- management_tools list --all | jq > "$ORIG_DIR"/data-access-pep.json
# echo " done"

# ades-pep
echo -n "Dumping policy for ades-pep to $ORIG_DIR/ades-pep.json..."
kubectl -n proc exec -it svc/proc-ades-pep -c proc-ades-pep -- management_tools list --all > "$ORIG_DIR"/ades-pep.json
echo " done"

# workspace-api-pep
echo -n "Dumping policy for workspace-api-pep to $ORIG_DIR/workspace-api-pep.json..."
kubectl -n rm exec -it svc/workspace-api-pep -c workspace-api-pep -- management_tools list --all > "$ORIG_DIR"/workspace-api-pep.json
echo " done"

# dummy-service-pep
echo -n "Dumping policy for dummy-service-pep to $ORIG_DIR/dummy-service-pep.json..."
kubectl -n test exec -it svc/dummy-service-pep -c dummy-service-pep -- management_tools list --all > "$ORIG_DIR"/dummy-service-pep.json
echo " done"

# pdp
echo -n "Dumping policy for pdp to $ORIG_DIR/pdp.json..."
kubectl exec -it svc/pdp-engine -c pdp-engine -- management_tools list --all > "$ORIG_DIR"/pdp.json
echo " done"

#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

trap "cd '${ORIG_DIR}'" EXIT

# ades-pep
echo -n "Dumping policy for ades-pep to $ORIG_DIR/pep.json..."
kubectl -n proc exec -it svc/proc-ades-pep -c proc-ades-pep -- management_tools list --all | jq > "$ORIG_DIR"/pep.json
echo " done"

# pdp
echo -n "Dumping policy for pdp to $ORIG_DIR/pdp.json..."
kubectl exec -it svc/pdp-engine -c pdp-engine -- management_tools list --all | sed "s/'/\"/g" > "$ORIG_DIR"/pdp.json
echo " done"

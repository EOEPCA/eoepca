#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

onExit() {
  cd "${ORIG_DIR}"
}
trap onExit EXIT

main() {
  if [ -z "$1" ]; then
    dumpAll
  else
    dumpDeployment "$@"
  fi
}

dumpAll() {
  dumpDeployment proc ades-pep
  dumpDeployment rm combined-rm-pep
  # dumpDeployment rm resource-catalogue-pep
  # dumpDeployment rm data-access-pep
  dumpDeployment rm workspace-api-pep
  dumpDeployment test dummy-service-pep
  dumpDeployment um pdp-engine nojson
}

dumpDeployment() {
  namespace="${1}"
  deployment="${2}"
  print_json="$( [ "${3}" = "nojson" ] && echo "" || echo "| jq" )"
  dumpfile="${ORIG_DIR}/${deployment}.json"

  echo -n "Dumping policy for ${namespace}/${deployment} to ${dumpfile}"
  cmd="kubectl -n "${namespace}" exec -it deploy/"${deployment}" -c "${deployment}" -- management_tools list --all ${print_json}"
  eval "${cmd}" > "${dumpfile}"
  echo " done"
}

main "$@"

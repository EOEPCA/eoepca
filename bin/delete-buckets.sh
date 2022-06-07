#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

trap "cd '${ORIG_DIR}'" EXIT

export OS_CLOUD=ractest

main() {
  user_prefix="${1:-dummy-prefix}"
  ignore_pattern="${2:-dummy-ignore}"
  writeCloudsYaml develop c21467d0a0414252a79e29d38f03ff98
  projects=$(openstack project list | grep "project-${user_prefix}" | grep -v "${ignore_pattern}" | grep -v osc | awk '{ print $4 ":" $2 }')
  for p in $projects; do
    project_args=$(echo $p | awk -F: '{ print $1 " " $2 }')
    deleteContainers $project_args
  done
}

deleteContainers() {
  project_name="${1}"
  project_id="${2}"
  echo "Deleting containers in project=[${project_name}] with ID=[${project_id}]"

  # Delete containers
  writeCloudsYaml "${project_name}" "${project_id}"
  containers=$(openstack container list | grep "${user_prefix}" | awk '{ print $2 }')
  for container_name in $containers; do
    deleteContainer "${project_name}" "${container_name}"
  done
}

deleteContainer() {
  project_name="${1}"
  container_name="${2}"
  echo "  [${project_name}]: deleting container ${container_name}"
  openstack container delete --recursive "${container_name}"
}

writeCloudsYaml() {
  project_name="${1}"
  project_id="${2}"
  cat - <<EOF >clouds.yaml
clouds:
  ractest:
    auth:
      auth_url: https://cf2.cloudferro.com:5000/v3
      username: "richard.conway@telespazio.com"
      project_name: "${project_name}"
      project_id: ${project_id}
      user_domain_name: "cloud_17650"
      password: "%Pk3izCFctHcZQ"
    region_name: "RegionOne"
    interface: "public"
    identity_api_version: 3
EOF
}

main "$@"

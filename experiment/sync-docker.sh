#!/bin/bash

source experiment/run-library.sh

organization="${PARAM_organization:-Default Organization}"
manifest="${PARAM_manifest:-conf/contperf/manifest_SCA.zip}"
inventory="${PARAM_inventory:-conf/contperf/inventory.ini}"
local_conf="${PARAM_local_conf:-conf/satperf.local.yaml}"

test_sync_docker_count="${PARAM_test_sync_docker_count:-8}"
test_sync_docker_url_template="${PARAM_test_sync_docker_url_template:-https://registry-1.docker.io}"
test_sync_docker_max_sync_secs="${PARAM_test_sync_docker_max_sync_secs:-600}"

wait_interval=${PARAM_wait_interval:-50}

cdn_url_mirror="${PARAM_cdn_url_mirror:-https://cdn.redhat.com/}"
cdn_url_full="${PARAM_cdn_url_full:-https://cdn.redhat.com/}"

dl="Default Location"

opts="--forks 100 -i $inventory"
opts_adhoc="$opts -e @conf/satperf.yaml -e @$local_conf"


#section "Checking environment"
#generic_environment_check false


section "Sync docker repo"
ap 10-test-sync-docker.log \
  -e "test_sync_docker_count=$test_sync_docker_count" \
  -e "test_sync_docker_url_template=$test_sync_docker_url_template" \
  -e "test_sync_docker_max_sync_secs=$test_sync_docker_max_sync_secs" \
  playbooks/tests/sync-docker.yaml


section "Summary"
e SyncRepositories $logs/10-test-sync-docker.log
e PublishContentViews $logs/10-test-sync-docker.log
e PromoteContentViews $logs/10-test-sync-docker.log


section "Sosreport"
skip_measurement='true' ap sosreporter-gatherer.log \
   -e "sosreport_gatherer_local_dir='../../$logs/sosreport/'" \
  playbooks/satellite/sosreport_gatherer.yaml

junit_upload

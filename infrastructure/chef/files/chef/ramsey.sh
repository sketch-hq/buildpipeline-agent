#!/usr/bin/env bash

source /etc/profile
set -eu -o pipefail

CHEF_CLIENT=/usr/local/bin/chef-client
TIMEOUT=1500 # 25 Minutes
NOW=$(date -u +"%Y-%m-%dT%H:%M:%S%Z")

echo "[${NOW}] INFO: Running Chef Infra Client with a ${TIMEOUT}s timeout via /usr/local/bin/ramsey."
exec gtimeout --preserve-status --signal=KILL --kill-after=1 ${TIMEOUT} ${CHEF_CLIENT}

#!/usr/bin/env bash

source /etc/profile
set -eu -o pipefail

CHEF_CLIENT=/usr/local/bin/chef-client
TIMEOUT=3600 # 60 Minutes
NOW=$(date -u +"%Y-%m-%dT%H:%M:%S%Z")

echo "[${NOW}] INFO: Running Chef Infra Client with a ${TIMEOUT}s timeout via /usr/local/bin/ramsey."


if [[ $(uname -m) == 'arm64' ]]; then
  BREW_BIN_PATH=/opt/homebrew/bin/
else
  BREW_BIN_PATH=/usr/local/bin/
fi

exec ${BREW_BIN_PATH}/gtimeout --preserve-status --signal=KILL --kill-after=1 ${TIMEOUT} ${CHEF_CLIENT}

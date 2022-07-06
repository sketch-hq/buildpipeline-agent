#!/usr/bin/env bash

set -eux -o pipefail

# Remove this script itself so we don't leave any mess behind
rm /tmp/install.sh

# Move the chef config into the correct location and make root the owner
rm -rf /etc/chef && mv /tmp/chef /etc
chown -R root:wheel /etc/chef

# Download and install chef
curl -sL https://omnitruck.chef.io/install.sh | bash -s -- -v 16

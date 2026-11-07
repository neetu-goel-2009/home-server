#!/usr/bin/env bash
set -Eeuo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."
ansible home_servers --become --module-name command \
  --args /usr/local/sbin/home-server-postgresql-backup --ask-become-pass

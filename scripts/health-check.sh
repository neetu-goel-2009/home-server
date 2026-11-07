#!/usr/bin/env bash
set -Eeuo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."
ansible home_servers --become --module-name shell --args '
  echo "== host =="; hostnamectl --static; uptime
  echo "== memory =="; free -h
  echo "== filesystems =="; df -hT / /srv
  echo "== services =="; systemctl --no-pager --full status docker home-postgresql-backup.timer 2>&1 | sed -n "1,12p"
  echo "== containers =="; docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
  echo "== backup metric =="; cat /var/lib/node_exporter/textfile_collector/postgresql_backup.prom 2>/dev/null || true
' --ask-become-pass

#!/usr/bin/env bash
set -Eeuo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

if ! command -v ansible-playbook >/dev/null 2>&1; then
  echo "ansible-playbook is missing. Run scripts/bootstrap.sh in WSL or Linux first." >&2
  exit 1
fi
for playbook in playbooks/*.yml; do
  echo "Syntax check: ${playbook}"
  ansible-playbook --syntax-check "$playbook"
done
for script in scripts/*.sh; do
  bash -n "$script"
done
echo "Syntax checks passed. This does not deploy or prove runtime idempotency."

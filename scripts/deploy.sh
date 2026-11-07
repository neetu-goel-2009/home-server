#!/usr/bin/env bash
set -Eeuo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

usage() {
  echo "Usage: scripts/deploy.sh {discover|storage|base|security|docker|postgresql|backup|networking|monitoring|ollama} [--check|--apply]"
}
stage=${1:-}
mode=${2:---check}
case "$stage" in
  discover) playbook=playbooks/00-discover.yml ;;
  storage) playbook=playbooks/02-storage.yml ;;
  base) playbook=playbooks/01-base-server.yml ;;
  security) playbook=playbooks/03-security.yml ;;
  docker) playbook=playbooks/04-docker.yml ;;
  postgresql) playbook=playbooks/05-postgresql.yml ;;
  backup) playbook=playbooks/06-backup.yml ;;
  networking) playbook=playbooks/07-networking.yml ;;
  monitoring) playbook=playbooks/08-monitoring.yml ;;
  ollama) playbook=playbooks/09-ollama.yml ;;
  *) usage >&2; exit 2 ;;
esac
if [[ "$mode" != --check && "$mode" != --apply ]]; then usage >&2; exit 2; fi

become_args=()
vault_args=()
if [[ "$stage" != discover ]]; then become_args=(--ask-become-pass); fi
if [[ "$stage" == postgresql ]] || { [[ "$stage" == networking ]] && grep -Eq '^cloudflare_tunnel_enabled:[[:space:]]*true([[:space:]]|$)' inventory/group_vars/all.yml; }; then
  vault_args=(--ask-vault-pass)
fi

ansible-playbook --syntax-check "$playbook"
ansible-playbook "$playbook" --check --diff "${become_args[@]}" "${vault_args[@]}"
if [[ "$mode" == --apply && "$stage" != discover ]]; then
  echo "Applying ${stage}; confirm you have reviewed the check-mode diff and stage risks."
  ansible-playbook "$playbook" --diff "${become_args[@]}" "${vault_args[@]}"
fi

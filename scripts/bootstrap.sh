#!/usr/bin/env bash
set -Eeuo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

if ! command -v python3 >/dev/null 2>&1; then
  echo "Install Python 3 and python3-venv in your Ansible controller (WSL Ubuntu recommended)." >&2
  exit 1
fi
python3 -m venv .venv
.venv/bin/python -m pip install --upgrade pip
.venv/bin/python -m pip install 'ansible-core>=2.17,<3'
.venv/bin/ansible-galaxy collection install -r requirements.yml
echo "Bootstrap complete. Activate with: source .venv/bin/activate"

#!/usr/bin/env bash
set -Eeuo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."
ansible home_servers --become --module-name command --args 'docker run --rm hello-world' --ask-become-pass

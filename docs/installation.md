# Installation and staged operation

## Controller setup

Use WSL Ubuntu or another Linux workstation with Python 3.10+, Git and network access to the server over Tailscale. From the repository root run:

```bash
scripts/bootstrap.sh
source .venv/bin/activate
```

This creates a local virtual environment, installs `ansible-core` and the collections in `requirements.yml`. It does not connect to or alter the server. Keep `ansible.cfg` host-key checking enabled. Verify the SSH host key out of band, then ensure `superadmin` can use sudo. The inventory starts with key authentication; install your public key first if needed. Password-based SSH remains enabled until key login is tested.

## Inventory and secrets

Edit `inventory/hosts.yml` to set the current Tailscale address and SSH user. Edit `inventory/group_vars/all.yml` for hostname, timezone, paths, domains, image versions, resource limits and monitoring address. No disk UUID is configured because this approved layout does not mount another disk.

Copy `secrets/vault.example.yml` to the ignored working file, set a long unique PostgreSQL password and, after interactive Cloudflare tunnel creation, its token; then encrypt the file:

```bash
cp secrets/vault.example.yml secrets/vault.yml
ansible-vault encrypt secrets/vault.yml
ansible-vault edit secrets/vault.yml
```

The example contains only obvious placeholders. Never apply PostgreSQL or Cloudflare stages until the placeholders are replaced. To recover an encrypted file, use `ansible-vault edit`; do not decrypt it into a tracked plaintext file. Ansible commands prompt for the vault password. See `secrets/README.md` for Git handling.

## Stage sequence

Review the plan and risks before each stage. `scripts/deploy.sh STAGE --check` runs a syntax check and Ansible check mode with diff. After reviewing the predicted changes, apply that one stage with `scripts/deploy.sh STAGE --apply`. This runs check mode again, then the real playbook. The `--apply` flag is a deliberate second step; do not use it for an unreviewed stage.

| Stage | Command | Main changes and risks |
|---|---|---|
| 1. Discovery | `scripts/deploy.sh discover --check` | Read-only facts, disks, mounts, IPs and service status. |
| 2. Approved storage directories | `scripts/deploy.sh storage --check` then `--apply` | Creates `/srv` directories on the existing Ubuntu filesystem, adjusts directory modes/ownership only. No partition or mount changes. |
| 3. Base server | `scripts/deploy.sh base --check` then `--apply` | Package updates, essentials, hostname/timezone, resolver, time sync, log rotation and limits. May install available updates. |
| 4. Security | `scripts/deploy.sh security --check` then `--apply` | Installs Fail2ban, adds SSH configuration, Tailscale package and UFW. UFW becomes default-deny inbound after allowing SSH on `tailscale0`; verify Tailscale access first. Password SSH remains enabled. |
| 5. Docker | `scripts/deploy.sh docker --check` then `--apply` | Adds official Docker apt source, installs Engine/Compose, sets Docker root and log rotation, creates private networks. Docker restarts. Existing unmanaged Docker data/config causes a fail-closed stop. |
| 6. PostgreSQL | `scripts/deploy.sh postgresql --check` then `--apply` | Pulls the pinned official image, creates the database/config paths and starts PostgreSQL. No host port 5432. Verify free memory before applying. |
| 7. Backups | `scripts/deploy.sh backup --check` then `--apply` | Installs a root-only script and daily systemd timer at 02:30, keeps at most 30 completed daily sets, writes logs/metrics. |
| 8. Web and tunnel | `scripts/deploy.sh networking --check` then `--apply` | Starts Caddy and placeholder Nginx sites for `365code.in` and `harimaati.com`. Tunnel stays disabled until Cloudflare login, tunnel creation, DNS and token setup are complete. Public HTTPS needs Cloudflare edge TLS/HTTPS settings. |
| 9. Monitoring | `scripts/deploy.sh monitoring --check` then `--apply` | Starts Uptime Kuma on the configured Tailscale IP, private Prometheus and node-exporter. Configure website/PostgreSQL monitors in Kuma after deployment. |
| 10. Ollama | `scripts/deploy.sh ollama --check` then `--apply` | Disabled by default. Review RAM/storage and model size first, then explicitly enable the role. The playbook never downloads a model. |

The approved Stage 2 layout is on the same physical disk as Ubuntu. PostgreSQL and local backups therefore share a disk failure risk. Stage 4 changes firewall policy and stage 5 restarts Docker; review each diff and maintain the current Tailscale session. Do not run all stages together.

## Validation

```bash
scripts/validate.sh
ansible home_servers -m ping
ansible-playbook playbooks/00-discover.yml
ansible-playbook playbooks/01-base-server.yml --check --diff --ask-become-pass
```

For an actual idempotency check, run a stage once, then run it again and confirm Ansible reports no unintended changes. A check-mode run is only a prediction and does not prove runtime idempotence. Do not repeat PostgreSQL or networking stages until their impact on persistent data and services is understood. `scripts/test-docker.sh` explicitly pulls/runs Docker's `hello-world` test container after Docker deployment.

## Updating

Review image and package updates, read the release notes, take and verify a backup, adjust the pinned variables, run the stage in check mode, then apply only that stage. PostgreSQL major version upgrades require a separate dump/restore or `pg_upgrade` plan; changing `postgresql_version` alone is not a safe major upgrade.

## Adding a website

Add an entry to `website_sites` in group vars with its hostname, private upstream and pinned image. Add the hostname to `cloudflare_tunnel_ingress` and create its DNS/tunnel route in Cloudflare. Put application files under `/srv/data/apps/<site>`. Run check mode and review generated Compose/Caddy config before applying the networking stage. Never publish the app, database or admin port directly.

## Migration

Install the same controller tools, update inventory and environment variables for the new host, and run discovery first. Compare hardware/storage and approve a new storage proposal. Copy encrypted Vault data securely, restore verified PostgreSQL backups, then deploy one stage at a time. Do not copy `/etc/fstab` disk identifiers blindly. Change the monitoring Tailscale IP and Cloudflare routing as needed.

# Home Server Infrastructure as Code

Ansible project for staged setup of an Ubuntu home server. It manages base packages, SSH/Tailscale/UFW, Docker Compose services, private PostgreSQL, daily verified backups, Caddy/Cloudflare Tunnel, monitoring and an opt-in Ollama service.

## Discovery and approved storage

The verified target is an HP Compaq 6200 Pro SFF running Ubuntu **26.04.1 LTS** in Legacy BIOS mode. It has an Intel i3-2120 (2 cores/4 threads), 3.2 GiB RAM, integrated Intel graphics and about 175 GiB free in the Ubuntu root filesystem. This differs from the original expected Ubuntu 24.04. Both disks have Windows NTFS partitions; Ubuntu is on `/dev/sdb4` on the WDC disk.

The approved initial layout creates dedicated directories on the existing Ubuntu root filesystem: `/srv/data/postgresql`, `/srv/backups/postgresql`, `/srv/docker`, `/srv/data/ollama`, `/srv/data/apps`, and `/var/log/home-server`. Stage 2 never formats, repartitions, resizes, mounts, changes `/etc/fstab`, or touches Windows partitions. Database and local backups share one physical disk; this does not protect against disk failure. External/off-site backup remains to be configured.

See [architecture](docs/architecture.md), [storage layout](docs/storage-layout.md), [security](docs/security.md), [monitoring](docs/monitoring.md), [backup and restore](docs/backup-and-restore.md), [PostgreSQL administration](docs/postgresql-admin.md), [installation](docs/installation.md), [troubleshooting](docs/troubleshooting.md) and the [deployment checklist](docs/checklist.md).

## Project map

- `inventory/`: host connection and environment variables.
- `playbooks/00-discover.yml`: read-only discovery. `01` to `09` are independently run stages. `site.yml` stays read-only by default.
- `roles/`: common, user, storage, security, Tailscale, Docker, PostgreSQL, backup, Caddy, Cloudflare Tunnel, monitoring and Ollama tasks/templates.
- `docker/`: service deployment notes; rendered Compose projects are built from role templates and installed under `/etc/home-server`.
- `scripts/`: bootstrap, validation, staged deploy, backup, health check and Docker smoke-test entry points.
- `secrets/vault.yml`: safe placeholders only until replaced and encrypted with Ansible Vault.

## Prerequisites

- WSL Ubuntu or another Linux Ansible controller with Python 3.10+, Git and network access to the server over Tailscale.
- SSH access as `superadmin`, verified host key, and sudo privileges.
- Ansible Vault password. PostgreSQL password must be unique and long.
- For Cloudflare Tunnel: a Cloudflare account, domain, manually created remotely managed tunnel, and DNS/hostname routing configured in Cloudflare. No account credentials are fabricated.

## Bootstrap and configure

```bash
scripts/bootstrap.sh
source .venv/bin/activate
scripts/validate.sh
```

Set `ansible_host` in `inventory/hosts.yml`, review `inventory/group_vars/all.yml`, copy the example secrets file, replace placeholders and encrypt it:

```bash
cp secrets/vault.example.yml secrets/vault.yml
ansible-vault encrypt secrets/vault.yml
ansible-vault edit secrets/vault.yml
```

Run one numbered stage at a time. First review its check-mode diff:

```bash
scripts/deploy.sh discover --check
scripts/deploy.sh storage --check
```

After reviewing a stage's actions and risks, apply only that stage:

```bash
scripts/deploy.sh storage --apply
scripts/deploy.sh base --check
scripts/deploy.sh base --apply
```

See [the stage table](docs/installation.md#stage-sequence) for each command, risk and validation. Stage 4 enables default-deny inbound UFW after allowing SSH on `tailscale0`. Stage 5 configures Docker and restarts it. Stage 6 pulls PostgreSQL and starts its container. Stage 8 leaves Cloudflare disabled until account setup is complete. Stage 10 keeps Ollama disabled unless explicitly enabled in group vars; no model is downloaded.

## Common operations

```bash
scripts/deploy.sh postgresql --check       # preview a single stage
scripts/backup-now.sh                      # trigger an immediate backup
scripts/health-check.sh                    # remote host/container summary
scripts/test-docker.sh                     # pulls/runs hello-world after Docker setup
sudo /usr/local/sbin/verify-home-server-postgresql-backup /srv/backups/postgresql/DB_TIMESTAMP.dump
```

Ansible check mode predicts changes but does not prove idempotency. After a reviewed apply, run the same stage again and confirm it reports no unintended changes. Do not apply restore or disk operations without separately reviewing their specific target and impact.

## Security and migration

Secrets stay encrypted with Ansible Vault and are written to root/container-only files. Do not commit plaintext secrets, private keys, cloud credentials or `.env` files. Do not add `superadmin` to the Docker group; that is root-equivalent. No Docker TCP API, public PostgreSQL port, public Ollama port, or public SSH rule is configured.

For migration, run discovery first on the new host, compare hardware and filesystems, update inventory/host-specific variables, and approve a new storage proposal. Never copy `/etc/fstab` disk names or UUIDs without verifying them. Restore a verified PostgreSQL backup before routing production applications to the new server.
